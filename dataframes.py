"""
dataframes.py

Description: Demonstrate capabilities of pandas dataframes with streamlit 
Author: Jarrod Lilkendey
"""

import streamlit as st
import pandas as pd
import os

st.title("Pandas dataframes with streamlit")

st.write("Load a CSV file into a pandas dataframe to display with streamlit")

file_option = st.radio(
    "CSV file option",
    ["Use a sample file", "Upload my CSV"],
)

def render_dataframe_with_statistics(file):
    df = pd.read_csv(file)

    st.write("### Data Preview")
    st.dataframe(df)

    st.write("### Summary Statistics")
    st.write(df.describe())

if file_option == "Upload my CSV":
    uploaded_file = st.file_uploader("Choose a file")
    if uploaded_file is not None:
        render_dataframe_with_statistics(uploaded_file)

if file_option == "Use a sample file":
    sample_csv_file_path = st.selectbox(
        "Sample CSV file",
        ("data/csv/action_movies.csv", "data/csv/south_park_characters.csv", "data/csv/sample_weather_data.csv"),
        index=None,
        placeholder="Select sample CSV file..."
    )

    st.write("You selected:", sample_csv_file_path)

    if sample_csv_file_path is not None:
        if os.path.exists(sample_csv_file_path):
            render_dataframe_with_statistics(sample_csv_file_path)
        else:
            st.error(f"File not found at {sample_csv_file_path}")

