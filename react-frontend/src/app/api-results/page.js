"use client"; // Add this for React Server Components, if you're using Next.js or similar

import React, { useState, useEffect } from "react";

export default function ApiResultsPage() {
  const [tables, setTables] = useState([]);
  const [selectedTable, setSelectedTable] = useState("");
  const [columns, setColumns] = useState([]);
  const [data, setData] = useState([]);
  const [hasBeenModified, setHasBeenModified] = useState({});
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [sortOrder, setSortOrder] = useState("ASC");
  const [selectedColumn, setSelectedColumn] = useState("");
  const [editedData, setEditedData] = useState({});
  const [deletedRows, setDeletedRows] = useState([]);
  const [primaryKeyColumn, setPrimaryKeyColumn] = useState("");
  const [updateSuccessful, setUpdateSuccessful] = useState(false);
  const [deleteSuccessful, setDeleteSuccessful] = useState(false);

  // Fetching table names
  useEffect(() => {
    const fetchTableNames = async () => {
      try {
        const response = await fetch("http://127.0.0.1:5000/api/tables/getTableNames");
        if (!response.ok) {
          const errorMessage = await response.text();
          throw new Error(`Failed to fetch table names: ${errorMessage}`);
        }
        const data = await response.json();
        const extractedTableNames = data.nume_tabele
          ? data.nume_tabele.map((table) => table[0])
          : [];
        setTables(extractedTableNames);
      } catch (error) {
        setError(error.message);
      } finally {
        setLoading(false);
      }
    };

    fetchTableNames();
  }, []);

  // Fetching columns
  useEffect(() => {
    if (!selectedTable) return;

    const resetState = () => {
      setColumns([]);
      setData([]);
      setHasBeenModified({});
      setEditedData({});
      setDeletedRows([]);
      setSelectedColumn("");
    };

    resetState();

    const fetchTableColumns = async () => {
      try {
        const response = await fetch(
          `http://127.0.0.1:5000/api/tables/getTableColumns?table_name=${selectedTable}`
        );
        if (!response.ok) {
          const errorMessage = await response.text();
          throw new Error(`Failed to fetch table columns: ${errorMessage}`);
        }
        const data = await response.json();
        setPrimaryKeyColumn(data.pk || '');  // Set the primary key column
        setColumns(data.coloane || []);
      } catch (error) {
        setError(error.message);
      }
    };

    fetchTableColumns();
  }, [selectedTable]);

  // Fetching table data
  useEffect(() => {
    if (!selectedTable) return;

    const fetchTableData = async () => {
      try {
        const url = selectedColumn
          ? `http://127.0.0.1:5000/api/tables/getTableData?table_name=${selectedTable}&order_by=${selectedColumn}&sort_order=${sortOrder}`
          : `http://127.0.0.1:5000/api/tables/getTableData?table_name=${selectedTable}`;

        const response = await fetch(url);
        if (!response.ok) {
          const errorMessage = await response.text();
          throw new Error(`Failed to fetch table data: ${errorMessage}`);
        }
        const data = await response.json();
        setData(data.data || []);
        setHasBeenModified({});
        setEditedData({});
        setDeletedRows([]);
      } catch (error) {
        setError(error.message);
      }
    };

    fetchTableData();
  }, [selectedTable, selectedColumn, sortOrder]);

  // Handling sorting of the table
  const handleSort = (column) => {
    const newSortOrder = selectedColumn === column && sortOrder === "ASC" ? "DESC" : "ASC";
    setSortOrder(newSortOrder);
    setSelectedColumn(column);
  };

  // Handling input changes for editing
  const handleInputChange = (e, rowId, column) => {
    const updatedValue = e.target.value;
    setEditedData((prevEditedData) => {
      const updatedRow = { ...prevEditedData[rowId], [column]: updatedValue };
      return { ...prevEditedData, [rowId]: updatedRow };
    });
    setHasBeenModified((prevHasBeenModified) => {
      const updatedHasBeenModified = { ...prevHasBeenModified };
      if (!updatedHasBeenModified[rowId]) {
        updatedHasBeenModified[rowId] = {};
      }
      updatedHasBeenModified[rowId][column] = true;
      return updatedHasBeenModified;
    });
  };

  // Handling row deletion
  const handleDelete = (rowId) => {
    const rowToDelete = data.find((row) => row[primaryKeyColumn] === rowId);
    if (rowToDelete && !deletedRows.some((row) => row[primaryKeyColumn] === rowId)) {
      setDeletedRows([...deletedRows, rowToDelete]);
      setEditedData((prevEditedData) => {
        const updatedData = { ...prevEditedData };
        delete updatedData[rowId];
        return updatedData;
      });
      setData(data.filter((row) => row[primaryKeyColumn] !== rowId));
    }
  };

  // Saving changes (update and delete)
  const saveChanges = async () => {
    try {
      const deletedIds = deletedRows.map((row) => row[primaryKeyColumn]);
      const changes = Object.entries(editedData).map(([rowId, editedRow]) => {
        const originalRow = data.find((originalRow) => originalRow[primaryKeyColumn] === parseInt(rowId));
        if (JSON.stringify(originalRow) !== JSON.stringify(editedRow)) {
          return {
            id: rowId, modified_columns: Object.entries(editedRow)
                .map(([key, value]) => ({column: key, value}))
          };
        }
        return null;
      }).filter(Boolean);

      if (changes.length === 0 && deletedRows.length === 0) {
        alert("No changes or deletions to save.");
        return;
      }
      setUpdateSuccessful(true);
      setDeleteSuccessful(true);
      if (deletedRows.length > 0) {
        const deleteResponse = await fetch(`http://127.0.0.1:5000/api/tables/deleteRows`, {
          method: "POST",
          headers: {"Content-Type": "application/json"},
          body: JSON.stringify({
            table_name: selectedTable,
            ids: deletedIds,
            primaryKeyColumn: primaryKeyColumn
          }),
        });

        if (!deleteResponse.ok) {
          const errorMessage = await deleteResponse.text();
          alert(`Error deleting rows: ${errorMessage}`);
          setDeleteSuccessful(false);
        }
      }

      if (changes.length > 0) {
        const updateResponse = await fetch(`http://127.0.0.1:5000/api/tables/updateTableData`, {
          method: "POST",
          headers: {"Content-Type": "application/json"},
          body: JSON.stringify({
            table_name: selectedTable,
            changes: changes,
            pk_column: primaryKeyColumn
          }),
        });

        if (!updateResponse.ok) {
          const errorMessage = await updateResponse.text();
          alert(`Error updating rows: ${errorMessage}`);
          setUpdateSuccessful(false);
        }
      }
      if (updateSuccessful && deleteSuccessful) alert("Changes saved successfully!");

      const fetchUpdatedDataResponse = await fetch(
          `http://127.0.0.1:5000/api/tables/getTableData?table_name=${selectedTable}`
      );
      const updatedData = await fetchUpdatedDataResponse.json();
      if (fetchUpdatedDataResponse.ok) {
        setData(updatedData.data || []);
        setEditedData({});
        setHasBeenModified({})
        setDeletedRows([]);
      } else {
        const errorMessage = await fetchUpdatedDataResponse.text();
        alert(`Error fetching updated data: ${errorMessage}`);
      }
    } catch (error) {
      alert(error.message);
    }
  };

  return (
    <div style={{ margin: "20px" }}>
      <h2>API Results</h2>
      <select
        value={selectedTable}
        onChange={(e) => { setSelectedColumn(''); setSelectedTable(e.target.value); }}
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

      {error && <p style={{ color: "red" }}>{error}</p>}

      <table style={{ width: "100%", borderCollapse: "collapse", textAlign: "center", backgroundColor: "black", color: "white" }}>
        <thead>
          <tr>
            {columns.map((column) => (
              <th
                key={column}
                style={{
                  border: "1px solid #ddd",
                  padding: "8px",
                  cursor: "pointer",
                  backgroundColor: "#333",
                  color: "white",
                }}
                onClick={() => handleSort(column)}
              >
                {column}
                {selectedColumn === column && (
                  <span>{sortOrder === "ASC" ? " ↑" : " ↓"}</span>
                )}
              </th>
            ))}
            <th style={{ border: "1px solid #ddd", padding: "8px" }}>Actions</th>
          </tr>
        </thead>
        <tbody>
          {data.length === 0 ? (
            <tr>
              <td colSpan={columns.length + 1} style={{ textAlign: "center", padding: "10px" }}>No data available</td>
            </tr>
          ) : (
            data.map((row) => (
              <tr key={row[primaryKeyColumn]}>
                {columns.map((column) => (
                  <td key={column} style={{ border: "1px solid #ddd", padding: "8px" }}>
                    <input
                      type="text"
                      value={ hasBeenModified[row[primaryKeyColumn]]?.[column] === true ?
                          (editedData[row[primaryKeyColumn]]?.[column] ?
                              editedData[row[primaryKeyColumn]]?.[column] : "") : row[column] || "" }
                      onChange={(e) => {handleInputChange(e, row[primaryKeyColumn], column)}}
                      style={{
                        width: "100%",
                        padding: "5px",
                        border: "1px solid #ddd",
                        borderRadius: "4px",
                        backgroundColor: "#333",
                        color: "white",
                      }}
                    />
                  </td>
                ))}
                <td style={{ border: "1px solid #ddd", padding: "8px" }}>
                  <button
                    onClick={() => handleDelete(row[primaryKeyColumn])}
                    style={{
                      padding: "5px 10px",
                      backgroundColor: "red",
                      color: "white",
                      border: "none",
                      borderRadius: "4px",
                    }}
                  >
                    Delete
                  </button>
                </td>
              </tr>
            ))
          )}
        </tbody>
      </table>

      {data.length > 0 && (
        <button
          onClick={saveChanges}
          style={{
            marginTop: "20px",
            padding: "10px 20px",
            backgroundColor: "#4CAF50",
            color: "white",
            border: "none",
            borderRadius: "4px",
            cursor: "pointer",
          }}
        >
          Save Changes
        </button>
      )}
    </div>
  );
}
