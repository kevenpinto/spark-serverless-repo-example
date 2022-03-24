from pyspark.sql import SparkSession
from pyspark.sql.dataframe import DataFrame


def read_file(spark: SparkSession,
              file_uri: str) -> DataFrame:
    """
    :param spark: Spark Context
    :param file_uri: URI of the Input File
    :return: Spark DataFrame
    """
    return (spark
            .read
            .option("delimiter", ",")
            .option("header", "true")
            .csv(file_uri))
