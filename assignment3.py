from xmlrpc.client import DateTime
from pandas import read_csv, DataFrame
from datetime import datetime as dt, timedelta
from numpy.random import choice
from sim_parameters import TRASITION_PROBS, HOLDING_TIMES
from pprint import pprint


class SampleSimulation:
    """An object to run a Continuous-Time Markov Chain simulating weather
    predicions based on a set of probabilities.

    Arguments:
        transition_probabilities:
            a nested map specifing the weights of the edges of the graph.
        holding_times:
            a map specifing the holding time for each state.
    """

    def __init__(self, transition_probabilities, holding_times):
        self.graph = self.__transform_transitions(transition_probabilities)

        if any(not self.__check_transitions(t[1]) for t in self.graph.values()):
            raise RuntimeError("Transition probablities are incorrect.")

        self.holding_times = holding_times
        self.state = list(self.graph.keys())[0]
        self.time_left = holding_times[self.state]
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

    def __next_hour(self):
        if self.time_left <= 1:
            self.__transition()
        else:
            self.time_left -= 1
            self.time_in_state += 1

    def next_state(self):
        """Calculate and transition into the next state and return it."""
        self.__next_hour()
        return self.state

    def iterable(self):
        """Returns a generator object that advances one hour and yields the
        resulting state on each `next()` call."""
        while True:
            yield self.next_state()

    def simulate(self, days):
        """Runs the simulation for the specified amount of hours and
        returns a list of the number of occurences of each state."""
        states = {key: 0 for key in self.graph}
        for _ in range(days):
            states[self.next_state()] += 1
        return [(100 * p / days) for p in states.values()]


def get_group_sample_size(samples_size, country_data, country):
    return {
        p_group: round(samples_size[country] * p_group_value / 100)
        for p_group, p_group_value in country_data.loc[country][2:].items()
    }


def run(countries_csv_name, countries, sample_ratio, start_date, end_date):
    start_date = dt.strptime(start_date, "%Y-%m-%d")
    end_date = dt.strptime(end_date, "%Y-%m-%d")
    days = abs((end_date - start_date).days)
    
    print(days)

    # Read the countries CSV file
    country_data = read_csv(countries_csv_name, index_col=0)
    samples_size = {
        country: int(country_data.loc[country]["population"]) // sample_ratio
        for country in countries
    }
    pprint(samples_size)
    samples = {
        country: get_group_sample_size(samples_size, country_data, country)
        for country in countries
    }
    pprint(samples)

    simulated_timeseries = DataFrame(
        columns=[
            "person_id",
            "age_group_name",
            "country",
            "date",
            "state",
            "staying_days",
            "prev_state"
        ]
    )

    # Run the simulation
    person_id = 0
    for country in countries:
        for group in samples[country]:
            for _ in range(samples[country][group]):
                sim = SampleSimulation(TRASITION_PROBS[group], HOLDING_TIMES[group])
                for d in range(days):
                    state = sim.current_state()
                    step = sim.next_state()
                    pprint([
                        person_id, 
                        group,
                        country,
                        start_date + timedelta(days=d),
                        step,
                        sim.time_in_state,
                        state
                    ])
                    simulated_timeseries.loc[len(simulated_timeseries.index)] = [
                        person_id, 
                        group,
                        country,
                        start_date + timedelta(days=d),
                        step,
                        sim.time_in_state,
                        state
                    ]
                person_id += 1
    print(simulated_timeseries)






if __name__ == "__main__":
    run(
        "a3-countries.csv",
        ["Sweden"],
        1e6,
        "2021-04-01",
        "2022-04-30",
    )
