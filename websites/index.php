<!DOCTYPE html>
<html lang="EN">
    <head>
        <title>WebDock - Get Started</title>
        <style>
            html,
            html body {
                padding: 0;
                margin: 0;
                background-color: #181818;
            }

            body {
                height: 100vh;
                width: 100%;
                display: flex;
                align-items: center;
                justify-content: center;
            }

            body > div {
                text-align: center;
            }

            h1 {
                color: #ffffff;
            }

            h1 span {
                color: #ffa500;
            }

            p {
                color: rgba(255,255,255,0.75);
            }

            p span {
                color: #ffffff;
                display: inline-block;
                padding: 4px 8px;
                background-color: rgba(0,0,0,0.2);
            }
        </style>
    </head>
    <body>
        <div>
            <h1>Welcome to <span>WebDock</span></h1>
            <p>Get started with running: <span>./factory.sh create my-website</span></p>
        </div>
    </body>
</html>