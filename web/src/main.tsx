import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import App from "./App";
import "./index.css";

import "@mantine/core/styles.css";
import { MantineProvider, CSSVariablesResolver } from "@mantine/core";

import { QueryClient, QueryClientProvider } from "@tanstack/react-query"; // caches the fetched data so doesnt recall the fetch if already cached
import { HashRouter } from "react-router-dom"; // good for spa's
import { isEnvBrowser } from "./utils/misc";

if (isEnvBrowser()) {
    const root = document.getElementById("root");

    // root!.style.backgroundImage = 'url("https://i.imgur.com/iPTAdYV.png")';
    root!.style.backgroundImage = 'url("https://cdn.discordapp.com/attachments/1047910129099608095/1296519148314038272/image.png?ex=6712950d&is=6711438d&hm=ff15f2a7ee2dfa2c9990ce65a505bef39d7975575f4ce604286034e662d89451&")';
    root!.style.backgroundSize = "cover";
    root!.style.backgroundRepeat = "no-repeat";
    root!.style.backgroundPosition = "center";
}

const resolver: CSSVariablesResolver = () => ({
    variables: {},
    light: {},
    dark: {
        "--mantine-color-scheme": "light",
    },
});

export const queryClient = new QueryClient({
    defaultOptions: {
        queries: {
            refetchOnWindowFocus: false,
            refetchOnReconnect: false,
            refetchOnMount: true,
        },
    },
});

createRoot(document.getElementById("root")!).render(
    <StrictMode>
        <QueryClientProvider client={queryClient}>
            <HashRouter>
                <MantineProvider defaultColorScheme="dark" cssVariablesResolver={resolver}>
                    <App />
                </MantineProvider>
            </HashRouter>
        </QueryClientProvider>
    </StrictMode>
);
