from pyspark.sql import SparkSession
from typing import Optional


def start_spark(
        app_name: Optional[str],
        bucket: str
) -> SparkSession:
    """
    :param app_name: Name of the Spark App
    :return: SparkSession
    """

    if app_name:
        builder = SparkSession.builder.appName(f'{app_name}')
    else:
        builder = SparkSession.builder

    spark = builder.getOrCreate()
    spark.conf.set('temporaryGcsBucket', bucket)
    return spark
