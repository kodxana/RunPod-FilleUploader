const express = require('express');
const router = express.Router();
const path = require('path');
const { exec } = require('child_process');
const fs = require('fs');

router.use(express.json());


// Serve the Admin Dashboard page
router.get('/admin', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'admin.html'));
});

router.get('/get-root-password', (req, res) => {
    const passwordFilePath = path.join('/workspace', 'root_password.txt');
    fs.readFile(passwordFilePath, 'utf8', (err, data) => {
        if (err) {
            console.error(`Error reading root password file: ${err}`);
            return res.status(500).send('Could not read root password');
        }
        res.send(data);
    });
});

// Endpoint to trigger SSH setup
router.post('/setup-ssh', (req, res) => {
    const scriptPath = '/etc/runpod-uploader/scripts/ssh-setup.sh'

    exec(`bash ${scriptPath}`, (error, stdout, stderr) => {
        if (error) {
            console.error(`exec error: ${error}`);
            return res.status(500).json({ message: "SSH setup failed", error: stderr });
        }
        console.log(`stdout: ${stdout}`);
        console.error(`stderr: ${stderr}`);
        
        res.json({
            message: "SSH setup completed successfully.",
            details: stdout,
            windowsScriptPath: '/download/connect_windows.bat',
            linuxScriptPath: '/download/connect_linux.sh'
        });
    });
});

// Endpoint for downloading SSH setup files
router.get('/download/:filename', (req, res) => {
    const filename = req.params.filename;
    const filePath = path.join('/workspace', filename);

    // Check if the file exists and is allowed to be downloaded
    fs.access(filePath, fs.constants.F_OK, (err) => {
        if (err) {
            return res.status(404).send('File not found.');
        }

        // Specify the allowed filenames to prevent arbitrary file download
        if (['connect_windows.bat', 'connect_linux.sh', 'root_password.txt'].includes(filename)) {
            res.download(filePath, filename);
        } else {
            res.status(403).send('Access denied.');
        }
    });
});

router.get('/environment-variables', (req, res) => {
    // Gather your environmental variables
    const envVars = {
        RUNPOD_POD_ID: process.env.RUNPOD_POD_ID || 'Null',
        RUNPOD_PUBLIC_IP: process.env.RUNPOD_PUBLIC_IP || 'Null',
        CUDA_VERSION: process.env.CUDA_VERSION || 'Null',
        RUNPOD_DC_ID: process.env.RUNPOD_DC_ID || 'Null',
        RUNPOD_CPU_COUNT: process.env.RUNPOD_CPU_COUNT || 'Null'
    };

    // Send them as a JSON response
    res.json(envVars);
});

router.post('/install-tool/:toolName', (req, res) => {
    const toolName = req.params.toolName;
    let installCommand;

    switch (toolName) {
        case 'croc':
            installCommand = 'curl https://getcroc.schollz.com | bash';
            break;
        case 'tmux':
            installCommand = 'apt-get update && apt-get install -y tmux';
            break;
        case 'rsync':
            installCommand = 'apt-get update && apt-get install -y rsync';
            break;
        case 'gdown':
            // Assuming Python and pip are already installed
            installCommand = 'pip install gdown';
            break;
        // Add more cases as needed
        default:
            return res.status(400).json({ message: "Invalid tool name" });
    }

    exec(installCommand, { shell: '/bin/bash' }, (error, stdout, stderr) => {
        if (error) {
            console.error(`exec error: ${error}`);
            return res.status(500).json({ message: "Installation failed", error: stderr });
        }
        console.log(`stdout: ${stdout}`);
        res.json({ message: `${toolName} installed successfully` });
    });
});

router.post('/run-speedtest', (req, res) => {
    // Collect flags from request body
    const flags = req.body;
    let scriptOptions = "";

    // Add flags to the script options based on the request
    if (flags.packageUpdate) scriptOptions += " -p";
    if (flags.speedtestCli) scriptOptions += " -s";
    if (flags.civitai) scriptOptions += " -c";
    if (flags.huggingface) scriptOptions += " -f";
    if (flags.s3) scriptOptions += " -3";
    if (flags.all) scriptOptions += " -a";
    if (flags.broadbandTest) scriptOptions += " -b";
    if (flags.googlePing) scriptOptions += " -g";

    const scriptPath = '/etc/runpod-uploader/scripts/run-speedtest.sh'

    exec(`bash ${scriptPath}${scriptOptions}`, (error, stdout, stderr) => {
        if (error) {
            console.error(`exec error: ${error}`);
            return res.status(500).json({ message: "Speedtest failed", error: stderr });
        }
        
        res.json({
            message: "Speedtest completed successfully.",
            result: stdout
        });
    });
});

let timers = [];

router.post('/set-timer', (req, res) => {
    const { podId, action, duration } = req.body;
    const expiry = new Date(new Date().getTime() + duration * 60000); // Convert duration to milliseconds
    const timerId = setTimeout(() => {
        exec(`runpodctl ${action} pod ${podId}`, (error, stdout, stderr) => {
            if (error) {
                console.error(`Error executing runpodctl: ${error}`);
                return;
            }
            console.log(`Timer action ${action} executed for pod ${podId}.`);
        });
    }, duration * 60000);

    timers.push({ podId, action, expiry, timerId });
    res.json({ message: `Timer set for ${action}ing pod ${podId} after ${duration} minutes.` });
});

router.get('/active-timers', (req, res) => {
    const now = new Date();
    const activeTimers = timers.filter(timer => timer.expiry > now).map(timer => ({
        podId: timer.podId,
        action: timer.action,
        remaining: Math.round((timer.expiry - now) / 60000) // Remaining time in minutes
    }));
    res.json(activeTimers);
});



module.exports = router;