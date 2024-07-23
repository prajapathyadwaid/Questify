# Questify - PDF-based Chat-Bot

Questify is a chatbot application that enables users to query the content of PDF documents. It utilizes Natural Language Processing (NLP) and Generative AI techniques to provide detailed answers based on the content of uploaded PDFs.

## Features

- **Text Extraction**: Extracts and preprocesses text from PDF documents.
- **Contextual Understanding**: Uses Sentence Transformers and BERT for encoding and understanding context.
- **Generative Responses**: Integrates Google Generative AI to generate detailed answers.
- **User Interface**: Built with Flask for backend and Flutter for the front end.

## Limitations

- **Number Processing**: Does not handle numerical data or equations.
- **Table Processing**: Does not process tables or structured data within the PDF.

## API KEY
  
Obtain an API key from Google for Gemini 
and add it to the API_KEY variable in the BackEnd/data/api.py file.
