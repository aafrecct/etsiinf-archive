import csv
from dataclasses import field
from pandas import read_csv
from datetime import datetime as dt, timedelta
from numpy.random import choice
from sim_parameters import TRASITION_PROBS, HOLDING_TIMES
from helper import create_plot
from pprint import pprint

SAMPLE_STATES = TRASITION_PROBS[list(TRASITION_PROBS)[0]].keys()   

class Sample:

    id_counter = 0

    def __init__(self, group):
        self.id = Sample.id_counter
        Sample.id_counter += 1

        self.group = group
        self.graph = self.__transform_transitions(TRASITION_PROBS[group])

        if any(not self.__check_transitions(t[1]) for t in self.graph.values()):
            raise RuntimeError("Transition probablities are incorrect.")

        self.holding_times = HOLDING_TIMES[group]
        self.state = list(self.graph.keys())[0]
        self.time_left = self.holding_times[self.state]
        self.time_in_state = 0

    @staticmethod
    def __check_transitions(transitions):
        return all(0 <= x <= 1 for x in transitions) and sum(transitions) == 1

    @staticmethod
    def __transform_transitions(transitions):
        return {
            state: list(zip(*value.items())) for state, value in transitions.items()
        }

    def get_states(self):
        """Get a list of all the states registered in an instance."""
        return list(self.graph.keys())

    def current_state(self):
        """Get the current state of an instance."""
        return self.state

    def current_state_remaining_hours(self) :
        return self.time_left

    def set_state(self, state):
        """Sets the current state of the instance"""
        if state in self.graph.keys():
            self.state = state
            self.time_left = self.holding_times[self.state]
        else:
            raise ValueError("State given is not registered.")

    def __transition(self):
        current_node = self.graph[self.state]
        self.state = choice(current_node[0], None, False, current_node[1])
        self.time_left = self.holding_times[self.state]
        self.time_in_state = 0

    def __next(self):
        if self.time_left <= 1:
            self.__transition()
        else:
            self.time_left -= 1
            self.time_in_state += 1
        return self.state

    def next_state(self):
        """Calculate and transition into the next state and return it."""
        return self.state, self.__next()


def get_group_sample_size(samples_size, country_data, country):
    return {
        p_group: round(samples_size[country] * p_group_value / 100)
        for p_group, p_group_value in country_data.loc[country][2:].items()
    }


def simulation_rows(simulations, start_date, end_date):
    # Run the simulation
    date = start_date
    while date != end_date:
        datestr = date.strftime("%Y-%m-%d")
        for country, sample_list in simulations.items():
            for sample in sample_list:
                state, next = sample.next_state()
                yield (
                    sample.id, 
                    sample.group,
                    country,
                    datestr,
                    next,
                    sample.time_in_state,
                    state
                )
        date += timedelta(days=1)

def run(countries_csv_name, countries, sample_ratio, start_date, end_date):
    start_date = dt.strptime(start_date, "%Y-%m-%d")
    end_date = dt.strptime(end_date, "%Y-%m-%d")

    # Read the countries CSV file
    country_data = read_csv(countries_csv_name, index_col=0)
    samples_size = {
        country: int(country_data.loc[country]["population"]) // sample_ratio
        for country in countries
    }

    # Calculate the sample size for each group
    sample_sizes = {
        country: get_group_sample_size(samples_size, country_data, country)
        for country in countries
    }

    # Create a dictionary of simulations for eash sample, with countries as the keys
    # and grouped by date.
    simulations = {country: [] for country in countries}
    for country in countries:
        for group, size in sample_sizes[country].items():
            for _ in range(size):
                simulations[country].append(Sample(group))

    summary = {country: {} for country in countries}
    with open("a3-covid-simulated-timeseries.csv", "w") as ts_file:
        ts_writer = csv.writer(ts_file)
        ts_writer.writerow(("person_id", "age_group", "country", "date", "state", "staying_days", "prev_state"))
        for row in simulation_rows(simulations, start_date, end_date):
            ts_writer.writerow(row)
            if row[3] not in summary[row[2]]:
                summary[row[2]][row[3]] = {key: 0 for key in SAMPLE_STATES}
            summary[row[2]][row[3]][row[4]] += 1


    with open("a3-covid-summary-timeseries.csv", "w") as summary_file: 
        summary_writer = csv.writer(summary_file)
        summary_writer.writerow(("date", "country", *SAMPLE_STATES))
        for country, country_summary in summary.items():
            for date, date_summary in country_summary.items():
                summary_writer.writerow((date, country, *date_summary.values()))
    
    create_plot("a3-covid-summary-timeseries.csv", countries)



if __name__ == "__main__":
    timeseries = run(
        "a3-countries.csv",
        ["Sweden", "Japan"],
        1e6,
        "2021-04-01",
        "2022-04-30",
    )
    
