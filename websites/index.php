<?php
    $websites = array_filter(scandir(__DIR__), fn ($file) =>
        $file[0] !== '.' && ! str_contains($file, '.php')
    );
?>

<!DOCTYPE html>
<html lang="EN">
    <head>
        <title>WebDock - Get Started</title>
        <style>
            *,
            *:before,
            *:after {
                box-sizing: border-box;
            }

            html,
            html body {
                padding: 0;
                margin: 0;
                background-color: #181818;
                color: #ffffff;
            }

            body {
                font-family: ProximaNova,
                             -apple-system,
                             BlinkMacSystemFont,
                             "Segoe UI",
                             Roboto,
                             "Helvetica Neue",
                             Arial,
                             sans-serif
            }

            .main {
                height: 100vh;
                width: 100%;
                display: flex;
                align-items: center;
                justify-content: center;
            }

            .main > div {
                height: 100%;
                padding: 40px 60px;
                width: 100%;
                display: flex;
                justify-content: center;
                align-items: center;
            }

            .main > div:nth-child(2) {
                background-color: rgba(0,0,0,0.3);
            }

            .main > div:nth-child(3) {
                background-color: rgba(0,0,0,0.8);
            }

            h1 {
                color: #ffffff;
            }

            span {
                color: #ffa500;
            }

            p {
                color: rgba(255,255,255,0.75);
                padding: 0;
            }

            .flex {
                display: flex;
                align-items: center;
                justify-content: center;
            }

            .command {
                padding: 5px 10px;
                border-radius: 5px;
                background-color: rgba(0,0,0,0.2);
                margin-left: 10px;
                color: rgba(255,255,255,0.4);
                border: solid 1px rgba(255,255,255,0.4);
            }

            .commandList {
                width: 100%;
            }

            .commands *+.command {
                margin-top: 15px;
            }

            .commands .command {
                margin-left: 0;
                width: 100%;
            }

            .commands .command p {
                margin: 0;
            }

            .websiteList {
                width: 100%;
                max-height: 100%;
                overflow-y: scroll;
            }

            .websiteList a {
                display: inline-block;
                color: rgba(255, 255, 255, 0.6);
                background-color: rgba(0,0,0,0.1);
                padding: 10px;
                border: solid 1px rgba(255,255,255,0.4);
                border-radius: 5px;
                text-align: left;
                text-decoration: none;
            }

            .websiteList a:hover {
                background-color: rgba(0, 0, 0, 0.5);
                color: #ffa500;
                border-color: #ffa500;
            }

            .websiteList a+a {
                margin-left: 10px;
                margin-bottom: 15px;
            }
        </style>
    </head>
    <body>
        <div class="main">
            <div class="welcome flex">
                <div>
                    <h1>Welcome to <span>W</span>eb<span>D</span>ock</h1>
                    <p>Webdock is a dockerised nginx setup which utilises php 8.2 for website development. Utilising a bespoke script that had been made specifically for this project. You will see a complete list of commands on this page.</p>
                    <p>This environment had been created specifically to help quickly get off the ground with web development, providing a script that will essentially take care of everything for you so you can put some concepts out of mind.</p>
                </div>
            </div>
            <?php if (count($websites) > 0) { ?>
                <div>
                    <div class="websiteList">
                        <h2>Websites <span>Available</span>:</h2>
                        <p>All of the websites that are currently installed within this environment can be found here, clicking on the links below will take you to the respective environment.</p>
                        <?php foreach ($websites as $website): ?>
                            <a href="http://www.<?= $website; ?>.test" target="_blank"><?= $website; ?></a>
                        <?php endforeach; ?>
                    </div>
                </div>
            <?php } ?>
            <div class="commands flex">
                <div class="commandList">
                    <h2>Commands <span>Available</span>:</h2>
                    <div class="command">
                        <p>./factory.sh <span>create</span> {website}</p>
                    </div>
                    <div class="command">
                        <p>./factory.sh <span>remove</span> {website}</p>
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>
