import ctypes

#window title
ctypes.windll.kernel32.SetConsoleTitleW('Questify')
print('''
   ____                  __  _ ____     
  / __ \__  _____  _____/ /_(_) __/_  __
 / / / / / / / _ \/ ___/ __/ / /_/ / / /
/ /_/ / /_/ /  __(__  ) /_/ / __/ /_/ / 
\___\_\__,_/\___/____/\__/_/_/  \__, /  
                               /____/   
                                                                         
''')

print("Loading 1/3 ...", end="\r")

from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity
from google.generativeai import GenerativeModel
from transformers import BertTokenizer
import google.generativeai as genai
from flask import Flask, request
from data.api import API_KEY
import numpy as np
import spacy
import json
import fitz 
import re

print("Loading 2/3 ...", end="\r")
# Initialize Bert tokenizer and model for sentence encoding
tokenizer = BertTokenizer.from_pretrained('bert-base-uncased')
model = SentenceTransformer("multi-qa-MiniLM-L6-cos-v1")

# Configure access to Generative AI model (replace with your API key)
genai.configure(api_key=API_KEY)
gen_model = GenerativeModel(model_name="gemini-pro")
print("Loading 3/3 ...", end="\r")
# Load spaCy language model for sentence processing
nlp = spacy.load('en_core_web_sm')

app = Flask(__name__)

L_CONTEXT_SIZE = 4
R_CONTEXT_SIZE = 16
# Prompt for the generative mode
PROMPT = """I need you to act as a Retrieval Augmented Generator, I will give you the context and the question,
find an elaborated answer from the context, if you cannot find the answer just say that the 'the provided document 
dosent contain the answer for that' """

# Global variables to store PDF data
pdf_encodings = None,
chunks = None

# Global variable to store cached data 
cache = {}

# Function to extract text from a PDF document
def extract_text_from_pdf(path):
    doc = fitz.open(path)
    text = ""
    for page_num in range(len(doc)):
        page = doc.load_page(page_num)
        temp = page.get_text()
        text += f"  {temp}"
    doc.close()
    return text

# Function to preprocess text (lowercase, remove special characters, etc.)
def preprocess_text(pdf_text):
    clean_pdf_text = pdf_text.lower()
    clean_pdf_text = re.sub(r'\d+(\.\d+)*\.', '', clean_pdf_text)
    clean_pdf_text = re.sub(r'[^a-z ,.;!?]', '', clean_pdf_text)
    clean_pdf_text = re.sub(r'\s+', ' ', clean_pdf_text)
    return clean_pdf_text

# Function to split text into chunks based on word count
def split_into_chunks(text, max_words=50):
    doc = nlp(text)
    chunks = []
    current_chunk = []
    current_word_count = 0
    for sent in doc.sents:
        words = tokenizer.tokenize(str(sent))
        sentence_word_count = len(words)
        if current_word_count + sentence_word_count > max_words:
            chunks.append(' '.join(current_chunk))
            current_chunk = [sent.text]
            current_word_count = sentence_word_count
        else:
            current_chunk.append(sent.text)
            current_word_count += sentence_word_count
    if current_chunk:
        chunks.append(' '.join(current_chunk))
    return chunks

# Function to encode text chunks using the sentence transformer model
def encode(chunks):
    global pdf_encodings
    pdf_encodings = []
    for chunk in chunks:
        pdf_encodings.append(model.encode(chunk).tolist())
    return pdf_encodings


# Function to extract context based on the question
def extract_context(pdf_encodings, chunks, question):
    pdf_encodings = np.array(pdf_encodings)
    question_encoding = model.encode([question])
    similarity = []
    for _, en in enumerate(pdf_encodings):
        similarity.append(cosine_similarity(
            question_encoding.reshape(1, -1), en.reshape(1, -1)))
    temp_chunks = chunks.copy()
    temp_sim = similarity.copy()
    context = ''
    for _ in range(3):
        argmax = np.argmax(temp_sim)
        start = argmax-L_CONTEXT_SIZE
        end = argmax+R_CONTEXT_SIZE
        if argmax < L_CONTEXT_SIZE:
            start = 0
        if argmax > len(temp_sim)-R_CONTEXT_SIZE:
            end = len(temp_sim)
        context += ' '.join(temp_chunks[start:end])
        temp_sim.pop(argmax)
        temp_chunks.pop(argmax)
    return context

# Function to generate output using a generative model
def generate_output(context, question):
    prompt = PROMPT+f"context:{context} , question: {question}"
    response = gen_model.generate_content(prompt)
    return response.text

# Function to load cached data from JSON file
def load_json():
    global cache
    with open(r'data\cache.json', 'r') as cache_file:
        content = cache_file.read() 
        cache = {} if content == "" else json.loads(content)

# Route to run the model and get answers
@app.route('/run_model/')
def run_model():
    try:
        global pdf_encodings
        global chunks
        question = request.args.get('question')
        context = extract_context(pdf_encodings, chunks, question)
        response = json.dumps(generate_output(context, question))
        return response
    except Exception as e:
        return json.dumps('error')

# Route to process PDF document
@app.route('/')
def run():
    try:
        global pdf_encodings
        global chunks
        global cache

        path = request.args.get('pdf')
        if path in cache:
            pdf_encodings = cache[path][0]
            chunks = cache[path][1]
            return json.dumps('Encoded')
        pdf_text = extract_text_from_pdf(path)
        clean_pdf_text = preprocess_text(pdf_text)
        chunks = split_into_chunks(clean_pdf_text)
        pdf_encodings = encode(chunks)
        cache[path] = [pdf_encodings,chunks]
        with open(r'data\cache.json', 'w') as cache_file:
            cache_file.write(json.dumps(cache))
        return json.dumps('Encoded')
    except Exception as e:
        return json.dumps('error')


if __name__ == "__main__":
    print("Loading 3/3 ...", end="\r")
    load_json()
    print("", end="\r")
    app.run()

