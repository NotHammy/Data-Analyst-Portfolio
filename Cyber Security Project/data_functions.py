################################################################################
# Data Functions
#
# This file contains functions that are useful for loading the data (in the
# format put together by Anton, unzipped) from a local directory. Download the
# data from the following link:
# https://drive.google.com/file/d/1QW_1VKpB27lbeHrlcRLE5JJ81WwRSN5_/view?usp=sharing
# Unzip the file and save it somewhere you know. The path to that directory (the
# one initially called 'Data Month') is the 'directory' argument in the functions
# below.
#
# This functions can be imported and used as follows:
#   import data_functions as f
#   june_df = f.load_month_data(6, 'path/to/data')
#   ...
#
# Feel free to add functions you think will be useful!
#
################################################################################

import pandas as pd
import numpy as np
import datetime
import os
import re

def load_month_data(month: int, directory: str, verbose=False, add_device_column=False):
    """"
    Loads the data for all devices for a given month.

    If a bad line is encountered while loading some data and a "Skipping line..."
    warning is printed, rerun this function with verbose=True to see which file
    caused the error.

    Args:
        month (int): The month to load data for, between 6 and 10 inclusive.
        directory (str): The directory ON YOUR LOCAL MACHINE where the data
                is stored. This directory should contain the subdirectories
                2019_06, 2019_07, ..., 2019_10.
        verbose (bool): Whether to print out file names as they are loaded.
        add_device_column (bool): Whether to add a column to the output
                dataframe containing the name of the device, inferred from
                the file name.
    """
    if not 6 <= month <= 10:
        raise ValueError('Month must be between 6 and 10 inclusive.')

    output = pd.DataFrame()

    for file in os.listdir(f'{directory}/2019_{month:02}'):
        if file.endswith('.csv'):
            if verbose: print(f'Loading {file}...')

            device_name = re.match(r'(.*)_\d{4}_\d{2}\.csv', file).group(1)

            device_df = pd.read_csv(
                f'{directory}/2019_{month:02}/{file}',
                on_bad_lines='warn',
                engine='python' if file == 'sony_smart_speaker_2019_09.csv' else None
                # The sony smart speaker in 2019_09 has a bad line that the
                # defaultengine can't handle
            )
            if add_device_column:
                device_df['device'] = device_name
            output = pd.concat([output, device_df], ignore_index=True)

    return output


def train_test_split_n_days(df: pd.DataFrame, start_date: datetime.datetime, n_days: int, silence_print=False):
    """
    Given a dataframe, a start date (start_date) and a number of days (n_days),
    this function returns:
    - a training dataset (X_train, y_train) containing N days of data from start_date
    - a test dataset (X_test_1, y_test_1) containing the next N days' worth of data
    - a second test dataset (X_test_2, y_test_2) containing the next N days' worth of data
    - a third test dataset (X_test_3, y_test_3) containing the next N days' worth of data

    These are returned in the order X_train, y_train, X_test_1, y_test_1, X_test_2,
    y_test_2, X_test_3, y_test_3.

    NOTE: this function doesn't alter the columns in any way, aside from dropping
    start_date. Ensure that the input dataframe has already had any other unwanted
    columns removed.

    These datasets are used to train a model on N days of data (from any defined
    start_date), and see how that model would perform over the next three groups
    of N days. For example, if I trained a model on 1 week of data, I could then
    test it on each of the next three weeks to see how well its performance fares
    over time.

    Args:
        df (pd.DataFrame): a dataframe which must include the 'start_date' column,
                and must also include at least n_days * 4 worth of data from start_date
        start_date (datetime.datetime): the first date from which n_days of data
                will be used for training - please ensure there are at least
                n_days * 4 days of data after this date
        n_days (int): the number of days to include in each split
        silence_print (bool): whether to silence the print messages displaying
                the dataset sizes
    """
    assert type(start_date) == datetime.datetime, 'start_date must be a datetime.datetime object'
    assert 'start_date' in df.columns, 'df must include a "start_date" column'
    df['start_date'] = pd.to_datetime(df['start_date'])

    # Training data
    train_end_date = start_date + datetime.timedelta(days=n_days)
    train = df[(df['start_date'] >= start_date) & (df['start_date'] < train_end_date)]
    X_train = train.drop(columns=['device'])
    y_train = train['device']

    # Test data
    test_1_end_date = train_end_date + datetime.timedelta(days=n_days)
    test_1 = df[(df['start_date'] >= train_end_date) & (df['start_date'] < test_1_end_date)]
    X_test_1 = test_1.drop(columns=['device'])
    y_test_1 = test_1['device']

    test_2_end_date = test_1_end_date + datetime.timedelta(days=n_days)
    test_2 = df[(df['start_date'] >= test_1_end_date) & (df['start_date'] < test_2_end_date)]
    X_test_2 = test_2.drop(columns=['device'])
    y_test_2 = test_2['device']

    test_3_end_date = test_2_end_date + datetime.timedelta(days=n_days)
    test_3 = df[(df['start_date'] >= test_2_end_date) & (df['start_date'] < test_3_end_date)]
    X_test_3 = test_3.drop(columns=['device'])
    y_test_3 = test_3['device']
    test_3_last_date = test_3['start_date'].max()

    if len(X_test_3) == 0:
        raise ValueError('Not enough data to split into 4 groups of n_days')
    if not silence_print:
        print(f'Training and test data split by {n_days} days:')
        print(f'> Training set contains {format(X_train.shape[0], ",d")} samples, from {start_date.date()} up to {train_end_date.date()}')
        print(f'> Test set 1 contains {format(X_test_1.shape[0], ",d")} samples, from {train_end_date.date()} up to {test_1_end_date.date()}')
        print(f'> Test set 2 contains {format(X_test_2.shape[0], ",d")} samples, from {test_1_end_date.date()} up to {test_2_end_date.date()}')
        print(f'> Test set 3 contains {format(X_test_3.shape[0], ",d")} samples, from {test_2_end_date.date()} up to {min(test_3_end_date, test_3_last_date).date()}')

    return X_train, y_train, X_test_1, y_test_1, X_test_2, y_test_2, X_test_3, y_test_3
