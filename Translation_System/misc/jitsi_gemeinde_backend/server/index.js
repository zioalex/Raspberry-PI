const express = require('express');
const path = require('path');
const { exec } = require('child_process');
const app = express();
const port = process.env.PORT || 5000;

// Have Node serve the files for our built React app
app.use(express.static(path.resolve(__dirname, '../../jitsi_gemeinde_frontend/build')));

app.get('/shutdown', (req, res) => {
    // res.send(`stdout: SHUTDOWN Initiated`);
    exec('sudo shutdown -h now', (error, stdout, stderr) => {
      if (error) {
        console.error(`exec error: ${error}`);
        res.status(500).send('Error shutting down');
        return;
      }
      console.log(`stdout: ${stdout}`);
      console.error(`stderr: ${stderr}`);
      res.send('Shutting down...');
    
  });
});

app.get('/reboot', (req, res) => {
  // res.send(`stdout: SHUTDOWN Initiated`);
  exec('sudo reboot', (error, stdout, stderr) => {
    if (error) {
      console.error(`exec error: ${error}`);
      res.status(500).send('Error Rebooting');
      return;
    }
    console.log(`stdout: ${stdout}`);
    console.error(`stderr: ${stderr}`);
    res.send('Reboot...');
  
});
});

// All other GET requests not handled before will return our React app
app.get('*', (req, res) => {
  res.sendFile(path.resolve(__dirname, '../../jitsi_gemeinde_frontend/build', 'index.html'));
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});