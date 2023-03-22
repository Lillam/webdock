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
                text-align: center;
                height: 100%;
                padding: 40px;
            }

            h1 {
                color: #ffffff;
            }

            span {
                color: #ffa500;
            }

            p {
                color: rgba(255,255,255,0.75);
                margin: 0;
                padding: 0;
            }

            .flex {
                display: flex;
                align-items: center;
                justify-content: center;
            }

            .welcome {
                width: 66.666%;
            }

            .commands {
                width: 33.333%;
                background-color: rgba(0,0,0,0.5);
            }

            .command {
                padding: 5px 10px;
                border-radius: 5px;
                background-color: rgba(0,0,0,0.2);
                margin-left: 10px;
                color: rgba(255,255,255,0.4);
                border: solid 1px rgba(255,255,255,0.4);
            }

            .commands *+.command {
                margin-top: 15px;
            }
        </style>
    </head>
    <body>
        <div class="main">
            <div class="welcome flex">
                <div>
                    <h1>Welcome to <span>W</span>eb<span>D</span>ock</h1>
                    <div class="flex">
                        <p>Get started with running:</p>
                        <div class="command">
                            <p>./factory.sh <span>create</span> my-website</p>
                        </div>
                    </div>
                </div>
            </div>
            <div class="commands flex">
                <div>
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