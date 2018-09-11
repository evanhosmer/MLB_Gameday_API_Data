import os
import urllib.request, json
from urllib.parse import quote
from urllib.error import HTTPError
import csv
import sys

# Author: Evan Hosmer

def get_json_grid(date):
    '''
    INPUT: Date (example: 2018-05-09).
    OUTPUT: Game data for the input date.
    '''
    year, month, day = date.split('-')
    # Format url string with year, month, and day from input
    dateurl = ('https://gd2.mlb.com/components/game/mlb/year_{}/month_{}/day_{}/grid.json'.format(year, month, day))

    # Load in the json grid from the url
    try:
        with urllib.request.urlopen(dateurl) as url:
            data = json.loads(url.read().decode())
    except HTTPError:
        raise ValueError('Failed to collect data for specified date')

    return data

def get_game_data(grid, date):
    '''
    INPUT: JSON grid, desired date.
    OUTPUT: CSV delimited file of game data for the specified date.
    '''
    # Access the required dictionary
    games = grid['data']['games']['game']
    year, month, day = date.split('-')

    # Remove unnecessary information
    for d in games:
        if 'newsroom' in d:
            del d['newsroom']
        if 'game_media' in d:
            del d['game_media']

    # Create a csv file to store the data with name reflecting the date. Data stored in data directory.
    path = os.path.abspath('rockies.py')
    path = path.replace('rockies.py', "")
    daily_game_data = open(path + 'data/{}-{}-{}.csv'.format(year,month,day), 'w')

    # create the csv writer object
    csvwriter = csv.writer(daily_game_data)
    count = 0

    # iterate through list of dictionaries
    for game in games:
          if count == 0:
              header = game.keys()
              csvwriter.writerow(header)
              count += 1

          csvwriter.writerow(game.values())

    daily_game_data.close()

if __name__ == '__main__':

    # Acquire the json grid.
    data = get_json_grid(sys.argv[1])

    #Get game data and store in a csv file.
    get_game_data(data, sys.argv[1])
