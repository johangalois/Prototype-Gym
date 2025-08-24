# Prototype Gym – Automated Workout Management System

## Overview

Prototype Gym is an automated workout management solution designed to streamline the way personalized fitness routines are generated, mapped, and delivered to users.
The system integrates a custom web application with automated data processing scripts built on **Google Apps Script**, enabling dynamic management of workout plans without manual overhead.

## Key Features

* **Dynamic Web App Interface:**
  A clean and intuitive front-end allows administrators to manage and visualize workout routines and user assignments efficiently.

* **Automated Data Transfer & Cleaning:**
  Scripts handle the extraction, transformation, and loading (ETL) of data across multiple Google Sheets, maintaining referential integrity based on user IDs and dates.

* **Personalized Workout Emails:**
  The system sends daily emails to users with their personalized routines, including:

  * User name
  * Machine (with clickable links)
  * Exercise (with clickable links)
  * Sets, repetitions, estimated weights, and rest times
    Emails are triggered only when the current date and weekday match the user’s assigned schedule.

* **Data Mapping & Validation:**
  Automatically maps data between connected sheets, ensuring consistent naming conventions, correct formats, and eliminating duplicates or invalid entries.

* **Scalable Design:**
  Supports multiple trainers and users with ease. Designed to be extensible for future analytics and reporting features.

## Tech Stack

* **Google Apps Script:** For automation, data cleaning, and email scheduling.
* **Google Sheets:** As the central database for users, exercises, and workout plans.
* **Web App (HTML/CSS/JS):** Interface for administrators to manage routines.
* **Gmail API (Apps Script):** For sending customized emails to users.

## Workflow

1. Data is collected and stored in structured Google Sheets (users, exercises, evaluations).
2. Cleaning and mapping scripts process and normalize the data.
3. The web app enables visualization and management of workout plans.
4. Automated scripts send personalized routines to each user based on date and schedule.

## Benefits

* Eliminates manual work in preparing and sending workout routines.
* Ensures data accuracy and consistency.
* Improves user experience with personalized, well-structured communication.
* Easily adaptable for additional gyms or franchise scalability.

## Future Enhancements

* Integration with analytics dashboards (Looker Studio/BI tools).
* Mobile-friendly web app for trainers and users.
* Machine learning module for adaptive workout recommendations.



