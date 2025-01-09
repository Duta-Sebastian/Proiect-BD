import process from "next/dist/build/webpack/loaders/resolve-url-loader/lib/postcss";

let DOCKER_API_BASE_URL;

try {
    if (process.env.NODE_ENV === "production")
        DOCKER_API_BASE_URL = "/api";
} catch (error) {
    DOCKER_API_BASE_URL = "http://localhost:5000/api";
}

const config = {
    DOCKER_API_BASE_URL,
};

export default config;