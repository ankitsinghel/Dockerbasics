const express = require("express");

const app = express();

app.get("/", (req,res)=>{
    return res.send("hi")
})

app.listen(1200, ()=>{
    console.log("app is listining at port 1200 ")
})