"use strict";
const puppeteer = require(`${process.argv[2]}/puppeteer`);
const createPdf = async options => {
  let browser;
  try {
    browser = await puppeteer.launch({
      args: ["--no-sandbox", "--disable-setuid-sandbox"]
    });
    const page = await browser.newPage();
    await page.goto(options.input, { waitUntil: "networkidle2" });
    delete options.input;
    await page.pdf(options);
  } catch (err) {
    console.log(err.message);
  } finally {
    if (browser) {
      browser.close();
    }
    process.exit();
  }
};
const parseCmd = () => {
  let options = {
    margin: {
      top: "10mm",
      bottom: "10mm",
      left: "10mm",
      right: "10mm"
    },
    landscape: false,
    format: "A4", // Format takes precedence over width and height if set
    height: "297", // A4
    width: "210", // A4
    path: process.argv[process.argv.length - 1],
    input: process.argv[process.argv.length - 2],
    scale: 1.0,
    displayHeaderFooter: false,
    printBackground: true
  };
  for (let i = 3; i < process.argv.length - 2; i += 2) {
    const value = process.argv[i + 1];
    switch (process.argv[i]) {
      case "--page-size":
        options.format = value;
        break;
      case "--orientation":
        options.landscape = value === "Landscape";
        break;
      case "--zoom":
        options.scale = parseFloat(value);
        break;
      case "--width":
        delete options.format;
        options.width = value;
        break;
      case "--height":
        delete options.format;
        options.height = value;
        break;
      case "--margin-top":
        options.margin.top = value;
        break;
      case "--margin-bottom":
        options.margin.bottom = value;
        break;
      case "--margin-left":
        options.margin.left = value;
        break;
      case "--margin-right":
        options.margin.right = value;
        break;
      default:
        console.log("Unknown argument: " + value);
    }
  }
  return options;
};
createPdf(parseCmd());
