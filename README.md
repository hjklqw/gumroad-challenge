A Rails and React version of [Ask My Book](https://askmybook.com/), and its PDF to AI embeddings generation script.

The challenge's context is available [here](https://gumroad.notion.site/Product-engineering-challenge-f7aa85150edd41eeb3537aae4632619f).

# Running locally

Please follow the headers and steps below in order.

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

# Running tests

1. Ensure that all setup from the previous section (aside from step 3) has been completed.
2. Install RSpec (globally) with `rails g rspec:install` if needed.
3. Run `rspec`.

# Implementation notes

## Existing functionality

- All existing functionality has been implemented, with the exception of Text-to-Speech, as there was no sufficient free tier
- The HTML and CSS has been cleaned up and trimmed down (the page still looks the same)
- The 404 page has also been created. It will not trigger for question routes with a non-numeric ID (ex. `/question/asdf`); this is handled with an on-page error message.

## Extra functionality

- Case-insensitive question-matching is implemented in the backend, both to speed up the retrieval of existing answers, and to avoid making extra OpenAI calls for the same question
- An error message is displayed on the page if the question ID given is invalid. IDs that are not numeric will get a different error message.
- An env variable is fed into both the PDF-to-CSV generation script, and the backend of the app, for easier handling when running locally
