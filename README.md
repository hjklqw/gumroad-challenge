# Running locally

Please follow the following headers and steps in order.

## 1. Fundamental setup

1. Ensure you have the following installed on your system:

- Ruby
- yarn
- PostgreSQL

2. Create an `.env` file using the below sample:

```
OPENAI_API_KEY=sk-123456
PDF_NAME=book.pdf
```

Note that `PDF_NAME` will be used in both the PDF to CSV script, and the application itself.

Also ensure that PostgreSQL is running, and that you have the following environment variables:

- `POSTGRES_USERNAME`
- `POSTGRES_PASSWORD`

3. Install dependencies

```
bundle
```

## 2. Running the PDF to CSV script

1. Add your PDf file to the root of the project.
2. Run the following:

```
ruby scripts/pdf_to_pages_embeddings.rb
```

Ensure that the name of your PDf has either been set in `.env`, or is given via a `--pdf` parameter to that script.

## 3. Running the application

1. Move the generated files from the above script into `/app/assets/csvs`.

2. Setup DB

```
rake db:setup
```

3. Run app

```
bin/dev
```
