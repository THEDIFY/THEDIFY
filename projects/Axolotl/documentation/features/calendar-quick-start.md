# Calendar Feature Quick Start Guide

## Accessing the Calendar

1. Navigate to the Calendar page by clicking the Calendar icon in the navigation menu
2. The calendar will load showing your scheduled training sessions

## Creating a Manual Training Event

1. Click the **"Add Event"** button in the top right corner
   - OR click on any date in the calendar
2. Fill in the event details:
   - **Title**: Name of the training session (e.g., "Speed Training")
   - **Day**: Select the day of the week
   - **Start Time**: Choose the start time
   - **Duration**: Set session length in minutes (15-180)
   - **KPIs**: Enter performance metrics to track (comma-separated)
   - **Drills**: List specific drills to perform (comma-separated)
3. Click **"Save Event"** to add to your calendar

## Using AI Recommendations

1. Click the **"AI Recommendations"** button (purple button with sparkles icon)
2. Enter your training goal:
   - Example: "Improve defensive positioning"
   - Example: "Build sprint speed and acceleration"
3. Select your preferred time slot:
   - Day of the week
   - Start time
   - Session duration
4. Click **"Generate AI Recommendations"**
5. Review the AI-generated proposals:
   - Each proposal shows confidence score, KPIs, and specific drills
   - Read the rationale to understand why each session was recommended
6. Click on a proposal to select it
7. Click **"Add to Calendar"** to commit the selected session

## Calendar Views

Switch between different views using the buttons in the top right:
- **Month View**: See all events for the entire month
- **Week View**: Detailed weekly schedule with time slots
- **Day View**: Hour-by-hour breakdown of a single day

## Navigating the Calendar

- **Previous/Next**: Use arrow buttons to move between time periods
- **Today**: Jump back to the current date
- **Click Event**: Click any event to see its details

## Understanding AI Proposals

AI recommendations are based on:
- Your recent training history (last 12 weeks)
- Current skill levels and gaps
- Age-appropriate training guidelines
- Recovery time between sessions
- Weekly training volume limits

Each proposal includes:
- **Confidence Score**: How well the session matches your needs (0-100%)
- **KPIs**: Specific metrics to track during the session
- **Drills**: Detailed exercises to perform
- **Rationale**: Why this session was recommended

## Safety Features

The system automatically validates all training sessions:

- **Age Limits**: Maximum session duration based on age
  - Under 14: 60 min max per session
  - Under 16: 75 min max per session
  - Under 18: 90 min max per session
  - Adults: 120 min max per session

- **Weekly Volume**: Total weekly training time limits
  - Under 14: 180 min/week max
  - Under 16: 210 min/week max
  - Under 18: 240 min/week max
  - Adults: 300 min/week max

- **Recovery Time**: Minimum rest between high-intensity sessions
- **Intensity Checks**: Prevents dangerous combinations of high-intensity drills

If a session violates safety rules, the system will:
- Automatically adjust it if possible
- Reject it with explanation if adjustment isn't safe

## Tips for Best Results

1. **Be Specific with Goals**: More detailed goals produce better AI recommendations
   - Good: "Improve first touch control and passing accuracy"
   - Less effective: "Get better at soccer"

2. **Regular Updates**: Keep your calendar updated to help AI understand your patterns

3. **Balance Training Types**: Mix technical, physical, and tactical sessions

4. **Listen to Your Body**: The AI follows safety rules, but you know your body best

5. **Review Proposals**: AI provides multiple options - choose what fits your needs

## Troubleshooting

**Events not showing?**
- Refresh the page
- Check that you're logged in with the correct user ID

**Can't save event?**
- Ensure all required fields are filled (Title is required)
- Check that session doesn't violate safety rules

**AI recommendations not generating?**
- Ensure you've entered a training goal
- Try a different time slot
- Check your internet connection

**Need help?**
- Contact your coach or administrator
- Check the full documentation at `docs/CALENDAR_IMPLEMENTATION.md`
