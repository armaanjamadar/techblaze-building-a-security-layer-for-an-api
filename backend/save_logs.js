import fs from "fs";

function get_dt() {
  const currentDate = new Date();
  const year = currentDate.getFullYear();
  const month = (currentDate.getMonth() + 1).toString().padStart(2, "0"); // Months are zero-indexed, so we add 1
  const day = currentDate.getDate().toString().padStart(2, "0");

  const hours = currentDate.getHours().toString().padStart(2, "0");
  const minutes = currentDate.getMinutes().toString().padStart(2, "0");
  const seconds = currentDate.getSeconds().toString().padStart(2, "0");

  return `${year}-${month}-${day}-${hours}:${minutes}:${seconds}`;
}

export const save_log = (msg) => {
  try {
    let dt = get_dt();
    console.log(`[${dt}] ${msg} `);
    let server_log = JSON.parse(
      fs.readFileSync(`./server_log.json`).toString(),
    );
    server_log.push({
      datetime: dt,
      message: msg,
    });
    fs.writeFileSync(`./server_log.json`, JSON.stringify(server_log));
  } catch (err) {
    console.log(err);
  }
};
