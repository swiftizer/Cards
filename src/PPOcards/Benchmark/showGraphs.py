import json
import matplotlib.pyplot as plt
import numpy as np

# Load data from JSON file
with open('/Users/ser.nikolaev/Desktop/testing-and-debugging/src/PPOcards/Benchmark/BenchmarkResultsFinal.json', 'r') as f:
    data = json.load(f)

# Sort data by db type
data.sort(key=lambda x: x['db'])

# Create a figure with 9 subplots arranged in a 3x3 grid
fig, axs = plt.subplots(3, 4, figsize=(15, 10))

# Define db types and measure types
db_types = ['CoreData', 'Realm', 'Postgres']
measure_types = ['clock', 'cpu', 'memory']
measure_types_lbl = {'clock': 'Time', 'cpu': 'CPU', 'memory': 'Memory'}

averages = {measure_type: [] for measure_type in measure_types}

# Iterate over db types and measure types
for i, db_type in enumerate(db_types):
    for j, measure_type in enumerate(measure_types):
        # Extract measurements for the current db type and measure type
        measurements = [d['measures'][measure_type] for d in data if d['db'] == db_type]
        
        # Flatten the list of measurements
        measurements = [item for sublist in measurements for item in sublist]
        
        # Calculate average
        avg = np.mean(measurements)
        averages[measure_type].append(avg)
        
        # Plot measurements
        axs[j, i].plot(measurements, label='Measurements')
        
        # Plot average line
        axs[j, i].axhline(y=avg, color='r', linestyle='--', label=f'Average: {avg:.2g}')
        
        # Set title and labels
        axs[j, i].set_title(f'{db_type} {measure_types_lbl[measure_type]}')
        axs[j, i].set_xlabel('Index')
        axs[j, i].set_ylabel('Value')
        
        # Add legend
        axs[j, i].legend()

# Adjust spacing between subplots
plt.tight_layout()


# Plot histograms
for i, measure in enumerate(measure_types):
    axs[i, 3].bar(db_types, averages[measure])
    axs[i, 3].set_title(f'{measure_types_lbl[measure]} averages')
    axs[i, 3].set_xlabel('db type')
    axs[i, 3].set_ylabel('Average')

# Adjust spacing between subplots
plt.tight_layout()

# Show the figure
plt.show()
