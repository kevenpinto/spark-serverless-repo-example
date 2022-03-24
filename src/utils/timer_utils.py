# Import Python libraries.
from typing import Dict
import logging

# Import third party libraries.
from humanfriendly import format_timespan

# create logger
logger = logging.getLogger('serverless-spark-example')

def timer_args(name) -> Dict:
    """
    :param name: Name of Timer
    :return: Timer Dict
    """
    return {
        'name': name,
        'text': lambda secs: f"{name}: {format_timespan(secs)}",
        'logger': logger.info,
    }