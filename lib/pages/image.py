import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

# Create a new figure
fig, ax = plt.subplots(figsize=(10, 8))

# Define the architecture components
components = {
    "Flutter App": (0.5, 0.8),
    "State Management": (0.5, 0.65),
    "AI Services": (0.5, 0.55),
    "Local Database": (0.3, 0.35),
    "API Services": (0.7, 0.35),
    "Authentication Service": (0.3, 0.15),
    "Data Processing": (0.7, 0.15),
}

# Draw the components as rectangles
for component, (x, y) in components.items():
    ax.add_patch(mpatches.Rectangle((x - 0.15, y - 0.05), 0.3, 0.1, edgecolor='black', facecolor='lightblue', lw=2))
    ax.text(x, y, component, fontsize=10, ha='center', va='center')

# Draw arrows to indicate relationships
arrowprops = dict(facecolor='black', arrowstyle='->')

# From Flutter App to State Management and AI Services
ax.annotate("", xy=(0.5, 0.75), xytext=(0.5, 0.65), arrowprops=arrowprops)
ax.annotate("", xy=(0.5, 0.75), xytext=(0.5, 0.55), arrowprops=arrowprops)

# From State Management to Local Database and API Services
ax.annotate("", xy=(0.5, 0.6), xytext=(0.3, 0.35), arrowprops=arrowprops)
ax.annotate("", xy=(0.5, 0.6), xytext=(0.7, 0.35), arrowprops=arrowprops)

# From Local Database and API Services to Authentication Service and Data Processing
ax.annotate("", xy=(0.3, 0.3), xytext=(0.3, 0.15), arrowprops=arrowprops)
ax.annotate("", xy=(0.7, 0.3), xytext=(0.7, 0.15), arrowprops=arrowprops)

# Set the limits and remove axes
ax.set_xlim(0, 1)
ax.set_ylim(0, 1)
ax.axis('off')

# Title
plt.title('Travel Care Architecture Diagram', fontsize=14)

# Save the diagram as an image
plt.savefig('travel_care_architecture_diagram.png', bbox_inches='tight')
plt.show()
