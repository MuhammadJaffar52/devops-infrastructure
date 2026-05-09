import { useEffect, useState } from "react";
import { api } from "../api/backend";

export default function Dashboard() {
  const [data, setData] = useState(null);

  useEffect(() => {
    api.get("/").then(res => {
      setData(res.data);
    });
  }, []);

  return (
    <div>
      <h1>📊 Dashboard</h1>
      <pre>{JSON.stringify(data, null, 2)}</pre>
    </div>
  );
}
