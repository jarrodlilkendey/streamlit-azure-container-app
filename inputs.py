"""
inputs.py

Description: Display a sub selection of input elements supported by streamlit
Author: Jarrod Lilkendey
"""

import streamlit as st
import datetime

st.title("Inputs supported by streamlit")

st.header("button", divider=True)

left, middle, right = st.columns(3)
if left.button("Plain button", width="stretch"):
    left.markdown("You clicked the plain button.")
if middle.button("Emoji button", icon="😃", width="stretch"):
    middle.markdown("You clicked the emoji button.")
if right.button("Material button", icon=":material/mood:", width="stretch"):
    right.markdown("You clicked the Material button.")

st.header("checkbox", divider=True)

agree = st.checkbox("I agree")
if agree:
    st.write("Great!")

st.header("radio", divider=True)

genre = st.radio(
    "What's your favorite movie genre",
    [":rainbow[Comedy]", "***Drama***", "Documentary :movie_camera:"],
    index=None,
)

st.write("You selected:", genre)

st.header("selectbox", divider=True)

option = st.selectbox(
    "How would you like to be contacted?",
    ("Email", "Home phone", "Mobile phone"),
)

st.write("You selected:", option)

st.header("number_input", divider=True)

number = st.number_input("Insert a number")
st.write("The current number is ", number)

st.header("date_input", divider=True)

d = st.date_input("When's your birthday", datetime.date(2019, 7, 6))
st.write("Your birthday is:", d)


st.header("time_input", divider=True)

t = st.time_input("Set an alarm for", datetime.time(8, 45))
st.write("Alarm is set for", t)

st.header("text_input", divider=True)

title = st.text_input("Movie title", "Life of Brian")
st.write("The current movie title is", title)