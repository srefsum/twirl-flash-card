# twirl-flash-card
Flash card system for twirling competitions. 

![system diagram](https://github.com/srefsum/twirl-flash-card/blob/master/Doc/images/1.SystemDiagram.PNG) 

# System technology
Standard LAMP application, with ubuntu/linux, apache, mysql, perl/mojolicious, javascript

# Purpose
Collect scores from judges and display the aggregate on a big screen using standard web pages. The scores is available 1-2 seconds after all the judges has typed in their score. The judges see the progress of the other judges, but not their scores. 
The head judge see the completion of the scores, so they can lock the score to the database. When the scores are locked, they can be show on a big screen or be available to view on web for a short period. 

# Status
   Very alpha state, but proof of concept.
   Can be used for simple demonstrations.

# Licence 
   GLP 3.0
   
# TODO list:
   
   ## Primary tasks
- [x] Add project files       Completed.
- [x] Remove unused files     Completed.
- [x] Create mysql template   Completed.
    
   ## Develop (in no particular order)
    1. Add reorder 
    2. Add list of persons logged in and when
    3. Sort out internal start numbers
    4. Sort out Athlete state handling
    5. Start generating simple reports (xlsx/pdf)
    6. Find logos for troops and add
    7. Finish language settings across all pages
    8. Start using global config file
    9. Create apache sites-available/sites-enabled file
   10. Import data from excel sheet

   ##  Documentations needed!
    1. System requirements
    2. Installation guide
    3. Administration guide
    4. User guide for judges
    5. User guide for presenter
    6. User guide for video stream connection
        
![system diagram](https://github.com/srefsum/twirl-flash-card/blob/master/Doc/images/1.SystemDiagram.PNG) 
![Load the events](https://github.com/srefsum/twirl-flash-card/blob/master/Doc/images/2.LoadFiles.PNG)
![Activate the Athlete](https://github.com/srefsum/twirl-flash-card/blob/master/Doc/images/3.Activate.PNG)
![Score the Preformance](https://github.com/srefsum/twirl-flash-card/blob/master/Doc/images/4.Scores.PNG)
![Lock down the given Score](https://github.com/srefsum/twirl-flash-card/blob/master/Doc/images/5.ScoreLock.PNG)
![Flash the Score to the audience](https://github.com/srefsum/twirl-flash-card/blob/master/Doc/images/6.FlashScores.PNG)
![Store the scores for reports](https://github.com/srefsum/twirl-flash-card/blob/master/Doc/images/6.StoreScores.PNG)    

