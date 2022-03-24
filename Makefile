PROJECT_ID ?= <CHANGEME>
REGION ?= <CHANGEME>
PROJECT_NUMBER ?= $$(gcloud projects list --filter=${PROJECT_ID} --format="value(PROJECT_NUMBER)")
CODE_BUCKET ?= serverless-spark-code-repo-${PROJECT_NUMBER}
TEMP_BUCKET ?= serverless-spark-staging-${PROJECT_NUMBER}
DATA_BUCKET ?= serverless-spark-data-${PROJECT_NUMBER}
APP_NAME ?= $$(cat pyproject.toml| grep name | cut -d" " -f3 | sed  's/"//g')
VERSION_NO ?= $$(poetry version --short)
SRC_WITH_DEPS ?= src_with_deps

.PHONY: $(shell sed -n -e '/^$$/ { n ; /^[^ .\#][^ ]*:/ { s/:.*$$// ; p ; } ; }' $(MAKEFILE_LIST))

.DEFAULT_GOAL := help

help: ## This is help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

setup: ## Setup Buckets and Dataset for Demo
	@echo "Project=${PROJECT_ID}--${PROJECT_NUMBER}--${CODE_BUCKET}--${TEMP_BUCKET}"
	@gsutil mb -c standard -l ${REGION} -p ${PROJECT_ID} gs://${CODE_BUCKET}
	@gsutil mb -c standard -l ${REGION} -p ${PROJECT_ID} gs://${TEMP_BUCKET}
	@gsutil mb -c standard -l ${REGION} -p ${PROJECT_ID} gs://${DATA_BUCKET}
	@gsutil cp ./stocks.csv gs://${DATA_BUCKET}
	@bq mk --location=${REGION} -d --project_id=${PROJECT_ID} --quiet serverless_spark_demo
	@echo "The Following Buckets created - ${CODE_BUCKET}, ${TEMP_BUCKET}, ${DATA_BUCKET} and 1 BQ Dataset (serverless_spark_demo) Created in GCP"

clean: ## CleanUp Prior to Build
	@rm -Rf ./dist
	@rm -Rf ./${SRC_WITH_DEPS}
	@rm -f requirements.txt

build: clean ## Build Python Package with Dependencies
	@echo "Packaging Code and Dependencies for ${APP_NAME}-${VERSION_NO}"
	@mkdir -p ./dist
	@poetry update
	@poetry export -f requirements.txt --without-hashes -o requirements.txt
	@poetry run pip install . -r requirements.txt -t ${SRC_WITH_DEPS}
	@cd ./${SRC_WITH_DEPS}
	@find . -name "*.pyc" -delete
	@cd ./${SRC_WITH_DEPS} && zip -x "*.git*" -x "*.DS_Store" -x "*.pyc" -x "*/*__pycache__*/" -x ".idea*" -r ../dist/${SRC_WITH_DEPS}.zip .
	@rm -Rf ./${SRC_WITH_DEPS}
	@rm -f requirements.txt
	@cp ./src/main.py ./dist
	@mv ./dist/${SRC_WITH_DEPS}.zip ./dist/${APP_NAME}_${VERSION_NO}.zip
	@gsutil cp -r ./dist gs://${CODE_BUCKET}


run: ## Run the dataproc serverless job
	gcloud beta dataproc batches submit --project ${PROJECT_ID} --region ${REGION} pyspark \
	gs://${CODE_BUCKET}/dist/main.py --py-files=gs://${CODE_BUCKET}/dist/${APP_NAME}_${VERSION_NO}.zip \
	--subnet default --properties spark.executor.instances=2,spark.driver.cores=4,spark.executor.cores=4,spark.app.name=spark_serverless_repo_exemplar \
	--jars gs://spark-lib/bigquery/spark-bigquery-with-dependencies_2.12-0.23.2.jar \
	-- --project=${PROJECT_ID} --file-uri=gs://${DATA_BUCKET}/stocks.csv --temp-bq-bucket=${TEMP_BUCKET}