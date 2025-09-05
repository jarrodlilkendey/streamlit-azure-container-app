import streamlit as st

# Define the pages
home_page = st.Page("home.py", title="Home Page", icon="🏠")
dataframes_page = st.Page("dataframes.py", title="Dataframes", icon="👨‍💻")
inputs_page = st.Page("inputs.py", title="Inputs", icon="⌨️")
visuals_page = st.Page("visuals.py", title="Visualisations", icon="📊")

# Set up navigation
pg = st.navigation([home_page, dataframes_page, inputs_page, visuals_page])

# Run the selected page
pg.run()