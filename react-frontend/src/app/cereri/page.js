"use client";
import TopMenu from '@/app/menu/TopMenu';
import React, { useEffect, useState } from "react";
import config from "@/app/config/config";

export default function CereriPage() {
    const [tables] = useState(['Joined Data Filtered', 'Aggregated Data Having']);
    const [selectedTable, setSelectedTable] = useState("");
    const [tableData, setTableData] = useState([]);

    useEffect(() => {
        if (selectedTable) {
            const fetchData = async () => {
                try {
                    const response = await fetch(`${config.DOCKER_API_BASE_URL}/queries?queryType=${selectedTable}`);
                    const result = await response.json();
                    setTableData(result.data);
                } catch (error) {
                    console.error("Error fetching data:", error);
                }
            };
            fetchData();
        }
    }, [selectedTable]);

    return (
        <div style={{ margin: "20px" }}>
            <TopMenu />
            <h2>API Results</h2>
            <select
                value={selectedTable}
                onChange={(e) => setSelectedTable(e.target.value)}
                style={{
                    padding: "5px",
                    marginBottom: "20px",
                    border: "1px solid #ddd",
                    borderRadius: "4px",
                    backgroundColor: "black",
                    color: "white",
                }}
            >
                <option value="">Select a table</option>
                {tables.map((table) => (
                    <option key={table} value={table}>
                        {table}
                    </option>
                ))}
            </select>

            {selectedTable && (
                <table style={{ width: "100%", borderCollapse: "collapse", textAlign: "center", backgroundColor: "black", color: "white" }}>
                    <thead>
                        <tr>
                            {tableData[0] && Object.keys(tableData[0]).map((column) => (
                                <th key={column} style={{ border: "1px solid #ddd", padding: "8px", backgroundColor: "#333", color: "white" }}>
                                    {column}
                                </th>
                            ))}
                        </tr>
                    </thead>
                    <tbody>
                        {tableData.length === 0 ? (
                            <tr>
                                <td colSpan={Object.keys(tableData[0] || {}).length} style={{ textAlign: "center", padding: "10px" }}>No data available</td>
                            </tr>
                        ) : (
                            tableData.map((row, index) => (
                                <tr key={index}>
                                    {Object.keys(row).map((column) => (
                                        <td key={column} style={{ border: "1px solid #ddd", padding: "8px" }}>
                                            {row[column]}
                                        </td>
                                    ))}
                                </tr>
                            ))
                        )}
                    </tbody>
                </table>
            )}
        </div>
    );
}
