from pyspark.sql.dataframe import DataFrame
from pyspark.sql.functions import col, to_date


def save_file_to_bq(stocks_df: DataFrame,
                    table: str) -> int:
    """
    :param stocks_df: Dataframe
    :param table: table_name
    :return: Status
    """
    (stocks_df.withColumn("dt", to_date(col("date"), 'MMM d yyyy'))
     .drop("date")
     .write.format('bigquery')
     .mode("overwrite")
     .option('table', table)
     .save()
     )

    return 0
