const userId = 2872; //Go to your WTIS page and open ispector (F12). Search for userId (4 digit number)
const domainUsername = "viktor";
const domainPassword = process.env.MY_PASSWORD;

var job_limit = 8*60*60*1000;
var work_limit = 7.5*60*60*1000;

const axios = require('axios');
const cheerio = require('cheerio');
const moment = require('moment');
const FormData = require("form-data");
const fs = require("fs");
const cheerioTableparser = require('cheerio-tableparser');

let entries = "";

let session = fs.readFileSync(`${__dirname}/session.txt`, "utf8");
const user = {
    username: domainUsername,
    password: domainPassword,
    domain: 2,
};

async function login(user) {
    try {
        const response = await axios.post('http://wtis/newCore/async/login.php', user);
        const sessionId = response.headers['set-cookie'][0].split(';')[0];
        fs.writeFileSync(`${__dirname}/session.txt`, sessionId);
        console.log('Session saved!');
    } catch (error) {
        console.error(error);
    }
}

if (!session) {
    login(user);
}

// Set date
const args = process.argv.slice(2);
let date;
if (args.length > 0) {
    date = args[0];
} else {
    date = moment().format("YYYY-MM-DD");
}

const dailyDeltasForMonth = args.length > 1;

// Get table for specific date, parse, calculate and print
axios.get(`http://wtis.rt-rk.com/newCore/async/getDayLog.php?date=${date}&eid=${userId}`, {headers: {
    "Cookie": `domain=${user.domain}; ${session}`,
}}).then(res => {
    if (res.data.includes("Access denied")) {
        login(user);
    }
    $ = cheerio.load(res.data.toString());
    cheerioTableparser($);
    var data = [];
    var array = $("table").parsetable(false, false, false)
    array[0].forEach(function(d, i) {
        var Type = $("<div>" + array[0][i] + "</div>").text();
        var Location = $("<div>" + array[1][i] + "</div>").text();
        var Time = $("<div>" + array[2][i] + "</div>").text();
        var Processed = $("<div>" + array[3][i] + "</div>").text();
        var Valid = $("<div>" + array[4][i] + "</div>").text();
        entries = Type + " " + Location + " " +  Time + " " +  Processed + " " +  Valid + "\n";
        data.push(entries)
    }); 
    data.shift();
    data.pop();
    var processedEntries = processEntries(data.toString());
    printTimeMessages(processedEntries);
  })
  .catch(error => {
    console.error(error)
  });

function processEntries(entryContent){
    var formattedEntryContent = entryContent.replace(/\t/g, ' ').replace(/  +/g, ' ').replace(/,/g, '');
    var entries = [];
    string = formattedEntryContent.replace(/^(?=\n)$|^\s*|\s*$|\n\n+/gm, "")
    var lines = string.split("\n");
    var entry = undefined;
    for(var i = 0;i<lines.length;i++){
        var lineParts = lines[i].split(" ");
        var lineParts_len = lineParts.length;
        entry = {};
        if(lineParts[0] === "Entry"){
            entry.type = 0;
        }else entry.type = 1;
        var dateAndTime = lineParts[lineParts_len - 4] + "T" + lineParts[lineParts_len - 3];
        var time = new Date(dateAndTime);
        if(!isValidDate(time)) return null;
        entry.time = time;
        entries.push(entry);
    };
    return entries;
}

function isValidDate(date){
    return date instanceof Date && !isNaN(date);
}

function getTotalWorkTime(entries) {
    var totalWorkTime = 0;
    var previousEntry;

    entries.forEach(entry => {
        if (previousEntry && previousEntry.type === 0 && entry.type === 1) {
            totalWorkTime += entry.time - previousEntry.time;
        }
        previousEntry = entry;
    });

    if (previousEntry && previousEntry.type === 0) {
        totalWorkTime += Date.now() - previousEntry.time;
    }

    return totalWorkTime;
}

function getTotalPauseTime(entries) {
    var totalPauseTime = 0;
    var previousEntry;

    entries.forEach(entry => {
        if (previousEntry && previousEntry.type === 1 && entry.type === 0) {
            totalPauseTime += entry.time - previousEntry.time;
        }
        previousEntry = entry;
    });

    return totalPauseTime;
}

function getFirstEntryTime(entries) {
    return entries.length > 0 ? entries[0].time : null;
}

function getTotalJobTime(entries){
    var currentTime = new Date().getTime();
    var firstEntryTime = getFirstEntryTime(entries).getTime();
    
    return currentTime - firstEntryTime;
}

function reduceSameTypeConsecutiveEntries(entries) {
    // Remove entries of the same type that occur in groups of two or more
    for (let i = 0; i < entries.length - 1; i++) {
        while (entries[i].type === entries[i+1].type) {
            entries.splice(i, 1);
            if (i >= entries.length - 1) break;
        }
    }
    return entries;
}

function printTimeMessages(entries) {
    entries = reduceSameTypeConsecutiveEntries(entries);
    var firstEntryTime = getFirstEntryTime(entries);
    var totalWorkTime = getTotalWorkTime(entries);
    var totalJobTime = getTotalJobTime(entries);

    const A = totalWorkTime >= work_limit;
    const B = totalJobTime >= job_limit;
    const C = work_limit - totalWorkTime < job_limit - totalJobTime;

    if (dailyDeltasForMonth) {
        const totalWorkTimeDeltaString = getTimeDelta(totalWorkTime);
        if (totalWorkTimeDeltaString.startsWith('+')) {
            console.log('\x1b[32m%s\x1b[0m', `${date}:   ${totalWorkTimeDeltaString}`);
        } else {
            console.log('\x1b[91m%s\x1b[0m', `${date}:   ${totalWorkTimeDeltaString}`);
        }
    } else {
        console.log('\x1b[39m%s\x1b[0m', `\nLeave      Worked  Pauses`);

        const firstEntryTimeFormatted = new Date(firstEntryTime).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: false });
        const totalWorkTimeString = getTimeString(totalWorkTime);
        var totalPauseTime = getTotalPauseTime(entries);
        const totalPauseTimeString = getTimeString(totalPauseTime);
      
        if (A && B) {
            console.log('\x1b[7;49;92m%s\x1b[0m\x1b[38;5;210m%s\x1b[0m', ` Now `,`        ${totalWorkTimeString}    ${totalPauseTimeString}\n`);
        } else {
            const currentTimeFormatted = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: false });
            const remainingTime = A && B ? 0 : A || C ? job_limit - totalJobTime : work_limit - totalWorkTime;
            const remainingTimeString = getTimeString(remainingTime);
            const timeHome = new Date(Date.now() + remainingTime);
            const timeHomeFormatted = timeHome.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: false });
            
            console.log('\x1b[7;49;92m%s\x1b[0m\x1b[38;5;210m%s\x1b[0m', `${timeHomeFormatted}`, `        ${totalWorkTimeString}    ${totalPauseTimeString}`);
        }
    }
}

function getTimeString(time) {
    var hours = Math.floor(time / 1000 / 60 / 60);
    var minutes = Math.floor((time / 1000 / 60) % 60);

    // Add leading zero to minutes if less than 10
    minutes = (minutes < 10 ? '0' : '') + minutes;

    return hours + ':' + minutes;
}

function getTimeDelta(time) {
    var timeDelta = time - work_limit;
    var sign = '+'
    if (timeDelta < 0) {
        sign = '-'
        timeDelta = timeDelta * -1;
    }
    var timeDeltaString = getTimeString(timeDelta);
    return sign + timeDeltaString;
}
