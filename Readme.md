# Packaging and Running a PySpark Job On Google's Serverless Spark Service

### Pre-reqs
* Install [Python Poetry](https://python-poetry.org/docs/)

### Setup Repo (Already Done -- For Info Only)
* Create a new Repo using Poetry
```sh 
 poetry new --src spark-serverless-repo-exemplar
```
* Create a main.py directly under the src/ folder -- This is your main driver file
* Create any other Python Packages under the /src folder
* Add all 3rd Party Python Dependencies to the `pyproject.toml` file -- See [here](https://python-poetry.org/docs/pyproject#the-pyprojecttoml-file) for more Guidance
* Add the following Lines to your `pyproject.toml` file under the `[tool.poetry]` section
```sh
exclude = ["src/main.py"]
packages = [
    { include = "src/**/*.py" },
]
```
* By the end of these steps your Folder should look something like this
```shell
.
├── LICENSE
├── Makefile
├── README.rst
├── Readme.md
├── poetry.lock
├── pyproject.toml
├── src
│   ├── __pycache__
│   ├── main.py
│   ├── spark_serverless_repo_exemplar
│   │   ├── __init__.py
│   │   ├── read_file.py
│   │   └── save_to_bq.py
│   └── utils
│       ├── __init__.py
│       ├── __pycache__
│       └── spark_setup.py
├── stocks.csv
└── tests
    ├── __init__.py
    └── test_spark_serverless_repo_exemplar.py

```

### Setup the Example in GCP (Run Once Only)
Edit the `Makefile` and change the following 2 params
```shell
PROJECT_ID ?= <CHANGEME>
REGION ?= <CHANGEME>

#for example
PROJECT_ID ?= my-gcp-project-1234
REGION ?= europe-west2
```
Then run the following command from the Root Folder of this Repo
```shell
make setup
```
This will create the following:
* GCS Bucket `serverless-spark-code-repo-<PROJECT_NUMBER>` →Our Pyspark Code gets uploaded here
* GCS Bucket `serverless-spark-staging-<PROJECT_NUMBER>` →Used for BQ operations
* GCS Bucket `serverless-spark-data-<PROJECT_NUMBER>` → Our source csv file is in here 
* Bigquery Dataset called `serverless_spark_demo` in BigQuery


### Packaging you Pipeline for GCP
```shell
make build
```

### Run the Pipeline
```shell
make run
```