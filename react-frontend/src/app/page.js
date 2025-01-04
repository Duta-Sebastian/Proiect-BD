import Link from "next/link";

export default function Home() {
    return (
        <div>
            <h1>Welcome to the Home Page</h1>
            {/* Use Link without an anchor tag */}
            <Link href="/api-results">Go to API Results Page</Link>
        </div>
    );
}
