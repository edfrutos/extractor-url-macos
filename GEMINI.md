# GEMINI.md

## Project Overview

This project, `extractor-url`, is a Python tool designed to extract clean content from web pages. It can take a URL and return the content as plain text, the full HTML, or as Markdown.

The core logic is contained in a single file, `extractor_url.py`. The project provides both a command-line interface (CLI) and a graphical user interface (GUI) built with `tkinter`.

The main dependencies are:
- `requests` for fetching the web page.
- `trafilatura` and `beautifulsoup4` for parsing and extracting the main content from the HTML.
- `markdownify` for converting the cleaned HTML to Markdown.

The tool is designed to be robust, with features like a configurable user-agent, handling of relative URLs, and a post-processing step to clean up the generated Markdown.

## Building and Running

### Setup

To set up the project, install the dependencies from `requirements.txt`:

```bash
pip install -r requirements.txt
```

### Running the GUI

To run the graphical user interface, execute the `extractor_url.py` script without any arguments:

```bash
python extractor_url.py
```

Or with the `--gui` flag:

```bash
python extractor_url.py --gui
```

### Running the CLI

The command-line interface allows for more flexible and scriptable usage.

**Basic Usage:**

To extract the clean text from a URL and print it to the console:

```bash
python extractor_url.py <URL>
```

**Outputting HTML:**

To get the full HTML of a page:

```bash
python extractor_url.py <URL> --type html
```

**Outputting Markdown:**

To get the content as Markdown:

```bash
python extractor_url.py <URL> --type markdown
```

**Using a CSS Selector:**

To extract content from a specific part of the page, use the `--selector` option:

```bash
python extractor_url.py <URL> --type markdown --selector "#main-content"
```

**Saving to a File:**

To save the output to a file, use the `--output` option:

```bash
python extractor_url.py <URL> --type markdown --output content.md
```

## Development Conventions

The project has a `tests` directory, indicating that `pytest` is the testing framework.

To run the tests:

```bash
pytest
```

The project also includes a `.pylintrc` file, so `pylint` is used for linting.

The `PLAN.md` file outlines the future development direction, including adding more robust error handling, improving the CLI, and adding more tests. Any new contributions should align with the goals described in that document.
