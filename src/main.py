# Import Python libraries.
from typing import Optional
import argparse

# Import third party libraries.
from codetiming import Timer

# Import local modules.
from src.utils.spark_setup import start_spark
from src.utils.timer_utils import timer_args
from src.spark_serverless_repo_exemplar.read_file import read_file
from src.spark_serverless_repo_exemplar.save_to_bq import save_file_to_bq


def run(app_name: Optional[str],
        bucket: str,
        file_uri: str) -> None:
    """
    :param app_name: Spark App Name,
    :param bucket: Cloud Storage bucket for temporary BigQuery export
    :param file_uri: Location of File to be Read
    :return: None
    """
    total_time = Timer(**timer_args("Total run time"))
    total_time.start()

    dataset_name = "serverless_spark_demo"
    table_name = "stock_prices"

    with Timer(**timer_args('Spark Connection')):
        spark = start_spark(app_name=app_name,
                            bucket=bucket)

    with Timer(**timer_args('Read File From GCS')):
        stocks_df = read_file(spark=spark,
                              file_uri=file_uri)

    with Timer(**timer_args('Write DF to Bigquery')):
        status = save_file_to_bq(stocks_df=stocks_df,
                                 table=f'{dataset_name}.{table_name}')

    total_time.stop()
    print(Timer.timers)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()

    parser.add_argument(
        '--file-uri',
        type=str,
        dest='file_uri',
        required=True,
        help='URI of the GCS bucket, for example, gs://bucket_name/file_name')

    parser.add_argument(
        '--project',
        type=str,
        dest='project_id',
        required=True,
        help='GCP Project ID')

    parser.add_argument(
        '--temp-bq-bucket',
        type=str,
        dest='temp_bq_bucket',
        required=True,
        help='Name of the Temp GCP Bucket -- DO NOT add the gs:// Prefix')

    known_args, pipeline_args = parser.parse_known_args()

    run(app_name="serverless-spark-demo-pipeline",
        bucket=known_args.temp_bq_bucket,
        file_uri=known_args.file_uri)
