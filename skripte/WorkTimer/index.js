const userId = 2872; //Go to your WTIS page and open ispector (F12). Search for userId (4 digit number)
const domainUsername = "viktor";
const domainPassword = process.env.MY_PASSWORD;

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

// Parse command line arguments
const args = process.argv.slice(2);
const monthly = args[0] === "m";

function processMonth(year, month) {
    const daysInMonth = new Date(year, month, 0).getDate();
    var totalMilliseconds = 0;

    for (let day = 1; day <= daysInMonth; day++) {
        const formattedDay = day.toString().padStart(2, '0');
        const date = `${year}-${month}-${formattedDay}`;
        if (date > moment().format("YYYY-MM-DD")) break;  // Stop if date is in the future
        main(date)
        .then(dailyDeltaMilliseconds => {
            totalMilliseconds += dailyDeltaMilliseconds;
            if (date === moment().format("YYYY-MM-DD")) {
                var monthDelta = getTimeDelta(totalMilliseconds);
                console.log(`Month delta:  ${monthDelta}`);
            }
        })
        .catch(error => {
            
        });
    }
}

if (args.length === 0) {
    // No additional arguments, use today's date
    main(moment().format("YYYY-MM-DD"));
} else if (args[0] === "m") {
    // Month mode, with optional specific month and year
    const currentDate = new Date();
    const month = (args.length > 1 ? parseInt(args[1], 10) : currentDate.getMonth() + 1).toString().padStart(2, '0');
    const year = args.length > 2 ? parseInt(args[2], 10) : currentDate.getFullYear();

    processMonth(year, month);
} else {
    // Specific date provided
    main(args[0]);
}

function main(date){
    return new Promise((resolve, reject) => {
        // Get table for specific date, parse, calculate and print
        axios.get(`http://wtis.rt-rk.com/newCore/async/getDayLog.php?date=${date}&eid=${userId}`, {
                headers: {
                    "Cookie": `domain=${user.domain}; ${session}`,
                },
            }).
            then(res => {
            // if (res.data.includes("Access denied")) {
            //     login(user);
            // }
            //console.log(`${res.data}`);
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
            var ret = printTimeMessages(processedEntries, date);
            //console.log(`${data}`);
            resolve(ret);
          })
          .catch(error => {
            
          });
    });
}

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

function printTimeMessages(entries, date) {
    entries = reduceSameTypeConsecutiveEntries(entries);
    var firstEntryTime = getFirstEntryTime(entries);
    var totalWorkTime = getTotalWorkTime(entries);

    if (monthly) {
        const totalWorkTimeDeltaString = getTimeDelta(totalWorkTime - work_limit);
        const totalWorkTimeMinutes = Math.floor(totalWorkTime / 1000 / 60);
        const work_limitMinutes = Math.floor(work_limit / 1000 / 60);

        if (totalWorkTimeMinutes == work_limitMinutes) {
            console.log('\x1b[36m%s\x1b[0m', `${date}:       0`);
        } else if (totalWorkTimeDeltaString.startsWith('+')) {
            console.log('\x1b[32m%s\x1b[0m', `${date}:   ${totalWorkTimeDeltaString}`);
        } else {
            console.log('\x1b[91m%s\x1b[0m', `${date}:   ${totalWorkTimeDeltaString}`);
        }
        return totalWorkTime - work_limit;
    } else {
        console.log('\x1b[39m%s\x1b[0m', `\nArrived  Leave      Worked  Pauses`);

        const firstEntryTimeFormatted = new Date(firstEntryTime).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: false });
        //console.log(`${firstEntryTimeFormatted}`)
        const totalWorkTimeString = getTimeString(totalWorkTime);
        var totalPauseTime = getTotalPauseTime(entries);
        const totalPauseTimeString = getTimeString(totalPauseTime);

        if (totalWorkTime >= work_limit) {
            console.log('%s\x1b[7;49;92m%s\x1b[0m\x1b[38;5;210m%s\x1b[0m', `${firstEntryTimeFormatted}    `, ` Now`, `        ${totalWorkTimeString}    ${totalPauseTimeString}\n`);
        } else {
            const currentTimeFormatted = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: false });
            const remainingTime = work_limit - totalWorkTime;
            const timeHome = new Date(Date.now() + remainingTime);
            const timeHomeFormatted = timeHome.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: false });
            
            console.log('%s\x1b[7;49;92m%s\x1b[0m\x1b[38;5;210m%s\x1b[0m', `${firstEntryTimeFormatted}    `, `${timeHomeFormatted}`, `        ${totalWorkTimeString}    ${totalPauseTimeString}\n`);
        }
    }
}

function getTimeString(time) {
    var hours = Math.floor(time / 1000 / 60 / 60);
    var minutes = Math.floor((time / 1000 / 60) % 60);

    // Add leading zero to minutes if less than 10
    minutesWithZero = (minutes < 10 ? '0' : '') + minutes;
    if (hours === 0) {
        const str = minutes < 10 ? ' ' : '';
        return '  ' + str + minutes;
    } else {
        return hours + ':' + minutesWithZero;
    }
}

function getTimeDelta(timeDelta) {
    var sign = '+'
    if (timeDelta < 0) {
        sign = '-'
        timeDelta = timeDelta * -1;
    }
    var timeDeltaString = getTimeString(timeDelta);
    return sign + timeDeltaString;
}
