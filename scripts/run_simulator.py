import yaml

from simulator.simulator import Simulator

if __name__ == "__main__":
    config = yaml.safe_load(open("simulator/sim_config.yaml"))
    simulator = Simulator(config, [])
    simulator.run()