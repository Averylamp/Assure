# Assure

Assure is a prototype service for in-home location monitoring of elderly indivduals. Using wifi beacons, and a wearable device, Assure can detect  

The tech details: Assure contains a iOS front end app, a Flask server (which can be run locally, but we ran it on [Linode][linode]), and a Parse database (running on Heroku).

Each wifi beacon (and the wearable device itself) run embedded device code that is critical for the system to work.

Assure was created for the [MIT ConnectedCare Hackathon][care] during the weekend of April 22, 2017 by [Rachel Groberman][rachel], [Arlene Siswanto][arelene], [Avery Lamp][avery], [Ethan Weber][ethan], and [Kenny Friedman][kenny].

Check out a video demo of Assure here: [Assure Video][vid].



# Backend

The back end server is a locally hosted Flask server. To run, simply navigate to the folder and run `python server.py`. Its only dependency is [Flask][flask]

[flask]: http://flask.pocoo.org
[linode]: https://www.linode.com
[avery]: http://averylamp.me
[kenny]: http://kennethfriedman.org
[arelene]: https://www.linkedin.com/in/arlenesiswanto
[rachel]: https://www.linkedin.com/in/rachelgroberman
[ethan]: https://www.linkedin.com/in/ethan-weber-0901b4118

[care]: http://design.mit.edu/hackathon-2017
[vid]: https://www.youtube.com/watch?v=XDjdEDvuqbs