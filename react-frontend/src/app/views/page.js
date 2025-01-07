"use client";
import React, { useEffect, useState } from "react";
import TopMenu from "@/app/menu/TopMenu";
import config from "@/app/config/config";

export default function ViewsPage() {
  const [views, setViews] = useState([]);
  const [selectedView, setSelectedView] = useState("");
  const [viewData, setViewData] = useState([]);
  const [modifiedRows, setModifiedRows] = useState({});
  const [newRows, setNewRows] = useState([]);
  const [deletedRows, setDeletedRows] = useState([]);

  // Fetch views list
  useEffect(() => {
    const fetchViews = async () => {
      try {
        const response = await fetch(`${config.DOCKER_API_BASE_URL}/views/getViews`);
        const result = await response.json();
        setViews(result.views);
      } catch (error) {
        console.error("Error fetching views:", error);
      }
    };
    fetchViews();
  }, []);

  // Fetch data for the selected view
  const fetchData = async () => {
    if (selectedView) {
      try {
        const response = await fetch(`${config.DOCKER_API_BASE_URL}/views/getViewData?view_name=${selectedView}`);
        const result = await response.json();
        setViewData(result);
        setModifiedRows({});
        setNewRows([]);
        setDeletedRows([]);
      } catch (error) {
        console.error("Error fetching view data:", error);
      }
    }
  };

  useEffect(() => {
    fetchData(); // Re-fetch data when the view changes
  }, [selectedView]);

  // Handle edit changes
  const handleEditChange = (e, rowIndex, column) => {
    const value = e.target.value || null; // Allow null values
    const originalRow = viewData[rowIndex];

    setModifiedRows((prevState) => ({
      ...prevState,
      [rowIndex]: {
        original: prevState[rowIndex]?.original || originalRow,
        updated: {
          ...prevState[rowIndex]?.updated,
          [column]: value,
        },
      },
    }));
  };

  // Add a new empty row
  const handleAddRow = () => {
    setNewRows((prevState) => [
      ...prevState,
      { ...Object.keys(viewData[0] || {}).reduce((acc, key) => ({ ...acc, [key]: null }), {}) },
    ]);
  };

  // Handle new row changes
  const handleNewRowChange = (e, rowIndex, column) => {
    const value = e.target.value || null; // Allow null values
    setNewRows((prevState) =>
      prevState.map((row, index) =>
        index === rowIndex ? { ...row, [column]: value } : row
      )
    );
  };

  // Mark a row for deletion
  const handleDelete = (rowIndex) => {
    const rowToDelete = viewData[rowIndex];
    if (rowToDelete) {
      setDeletedRows((prevState) => [...prevState, rowToDelete]);
      setViewData((prevData) => prevData.filter((_, index) => index !== rowIndex));
      setModifiedRows((prevState) => {
        const updatedState = { ...prevState };
        delete updatedState[rowIndex];
        return updatedState;
      });
    }
  };

  // Insert new rows
const handleInsertRows = async () => {
  try {
    // Remove 'id' from new rows before sending them
    const rowsToInsert = newRows.map(({ id, ...rest }) => rest);

    const response = await fetch(`${config.DOCKER_API_BASE_URL}/views/insertViewData`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ view_name: selectedView, data: rowsToInsert }),
    });
    const result = await response.json();
    if (result && result.success) {
      console.log("New rows inserted successfully");
    } else {
      console.error("Error inserting rows:", result ? result.message : "No response");
    }
  } catch (error) {
    console.error("Error inserting rows:", error);
  } finally {
    fetchData(); // Re-fetch the data after the action, regardless of success or failure
  }
};

  // Update modified rows
  const handleUpdateRows = async () => {
    const updates = Object.values(modifiedRows).map(({ original, updated }) => ({
      original,
      updated,
    }));

    try {
      const response = await fetch(`${config.DOCKER_API_BASE_URL}/views/updateViewData`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ view_name: selectedView, data: updates }),
      });
      const result = await response.json();
      if (result && result.success) {
        console.log("Rows updated successfully");
      } else {
        console.error("Error updating rows:", result ? result.message : "No response");
      }
    } catch (error) {
      console.error("Error updating rows:", error);
    } finally {
      fetchData(); // Re-fetch the data after the action, regardless of success or failure
    }
  };

  // Delete rows
  const handleDeleteRows = async () => {
    try {
      const response = await fetch(`${config.DOCKER_API_BASE_URL}/views/deleteViewData`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ view_name: selectedView, data: deletedRows }),
      });
      const result = await response.json();
      if (result && result.success) {
        console.log("Rows deleted successfully");
      } else {
        console.error("Error deleting rows:", result ? result.message : "No response");
      }
    } catch (error) {
      console.error("Error deleting rows:", error);
    } finally {
      fetchData(); // Re-fetch the data after the action, regardless of success or failure
    }
  };

  return (
    <div style={{ margin: "20px", color: "white", backgroundColor: "black" }}>
      <TopMenu />
      <h2>Views Data</h2>

      <select
        value={selectedView}
        onChange={(e) => setSelectedView(e.target.value)}
        style={{
          padding: "5px",
          marginBottom: "20px",
          border: "1px solid #ddd",
          borderRadius: "4px",
          backgroundColor: "black",
          color: "white",
        }}
      >
        <option value="">Select a view</option>
        {views.map((view, index) => (
          <option key={index} value={view}>
            {view}
          </option>
        ))}
      </select>

      {selectedView && (
        <table style={{ width: "100%", borderCollapse: "collapse", textAlign: "center" }}>
          <thead>
            <tr>
              {viewData[0] && Object.keys(viewData[0]).map((column) => (
                <th key={column} style={{ border: "1px solid #ddd", padding: "8px" }}>
                  {column}
                </th>
              ))}
              {selectedView === "USER_CREDENTIALS_VIEW" && (
              <th>Action</th>
                  )}
            </tr>
          </thead>
          <tbody>
            {viewData.map((row, rowIndex) => (
              <tr key={rowIndex}>
                {Object.keys(row).map((column) => (
                  <td key={column} style={{ border: "1px solid #ddd", padding: "8px" }}>
                    <input
                      type="text"
                      value={modifiedRows[rowIndex]?.updated[column] ?? row[column] ?? ""}
                      onChange={(e) => handleEditChange(e, rowIndex, column)}
                      style={{ backgroundColor: "black", color: "white", padding: "5px" }}
                    />
                  </td>
                ))}
                <td>
                  {selectedView === "USER_CREDENTIALS_VIEW" && (
                  <button
                    onClick={() => handleDelete(rowIndex)}
                    style={{ padding: "5px", backgroundColor: "red", color: "white" }}
                  >
                    Delete
                  </button>)}
                </td>
              </tr>
            ))}
            {newRows.map((row, rowIndex) => (
              <tr key={`new-${rowIndex}`}>
                {Object.keys(row).map((column) => (
                  <td key={column} style={{ border: "1px solid #ddd", padding: "8px" }}>
                    <input
                      type="text"
                      value={row[column] || ""}
                      onChange={(e) => handleNewRowChange(e, rowIndex, column)}
                      style={{ backgroundColor: "black", color: "white", padding: "5px" }}
                    />
                  </td>
                ))}
                <td>
                  {selectedView === "USER_CREDENTIALS_VIEW" && (
                  <button
                    onClick={() =>
                      setNewRows((prev) => prev.filter((_, idx) => idx !== rowIndex))
                    }
                    style={{ padding: "5px", backgroundColor: "red", color: "white" }}
                  >
                    Delete
                  </button>
                      )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}

      {selectedView === "USER_CREDENTIALS_VIEW" && (
        <>
          <button
            onClick={handleAddRow}
            style={{ marginTop: "20px", padding: "10px", backgroundColor: "green", color: "white" }}
          >
            Add Row
          </button>
          <button
            onClick={handleInsertRows}
            style={{ marginTop: "20px", padding: "10px", backgroundColor: "blue", color: "white" }}
          >
            Insert Rows
          </button>
        </>
      )}
      {selectedView === "USER_CREDENTIALS_VIEW" && (
      <button
        onClick={handleUpdateRows}
        style={{
          marginTop: "20px",
          padding: "10px",
          backgroundColor: "orange",
          color: "white",
        }}
      >
        Update Rows
      </button>)}

      {selectedView === "USER_CREDENTIALS_VIEW" && (
      <button
        onClick={handleDeleteRows}
        style={{
          marginTop: "20px",
          padding: "10px",
          backgroundColor: "red",
          color: "white",
        }}
      >
        Delete Rows
      </button>)}
    </div>
  );
}
