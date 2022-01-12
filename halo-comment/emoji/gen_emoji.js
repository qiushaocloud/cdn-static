const path = require("path");
const fs = require("fs");

const resolve = (pathname) => path.resolve(__dirname, pathname);

class Emoji {
  constructor(name, description, category, style) {
    this.name = name;
    this.description = description;
    this.category = category;
    this.style = style;
  }
}

const config = {
  type: "haha",
  path: "haha",
  output: resolve("output.js"),
};

fs.readdir(resolve(config.path), (err, data) => {
  if (err) {
    throw new Error(err);
  }

  const emojis = data.filter((item) => item.includes("icon_"));
  const emojiData = emojis.map((item) => {
    const name = item.replace('icon_', '').replace(/\.(.+)$/, '');
    return `new Emoji('${name}', 'ZH-${name}', '${config.type}')`;
  });
  const emojiStr = `const ${config.type}Emoji = ${JSON.stringify(emojiData,null,2).replace(/"/g, "")}`.replace(/"/g, "").replace(/'/g, '"');
  console.log(emojiStr);
  fs.writeFile(config.output, emojiStr, "utf-8", (err) => {
    if (err) {
      throw new Error(err);
    }
    console.log("Emoji 生成完毕 😆😆😆");
  });
});
