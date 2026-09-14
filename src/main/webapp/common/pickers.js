(function () {
  function provinces() {
    return window.CN_REGIONS || [];
  }

  function closePicker() {
    var mask = document.getElementById("q-picker-mask");
    if (mask && mask.parentNode) {
      mask.parentNode.removeChild(mask);
    }
  }

  function pad2(n) {
    return n < 10 ? "0" + n : String(n);
  }

  function daysInMonth(y, m) {
    return new Date(y, m, 0).getDate();
  }

  function normalizeDate(raw) {
    var s = (raw || "").trim();
    if (!s) return "";
    var m = s.match(/^(\d{4})[./-](\d{1,2})[./-](\d{1,2})$/);
    if (m) return m[1] + "-" + pad2(+m[2]) + "-" + pad2(+m[3]);
    m = s.match(/^(\d{4})[./-](\d{1,2})$/);
    if (m) return m[1] + "-" + pad2(+m[2]) + "-01";
    m = s.match(/^(\d{4})$/);
    if (m) return m[1] + "-01-01";
    return s;
  }

  function parseRange(raw) {
    var s = (raw || "").trim();
    if (!s) return { start: "", end: "" };
    var parts = s.split(/\s*(?:~|～|至|到)\s*/);
    if (parts.length >= 2) {
      return { start: normalizeDate(parts[0]), end: normalizeDate(parts[1]) };
    }
    var y = s.match(/^(\d{4})\s*[-./]\s*(\d{4})$/);
    if (y) return { start: y[1] + "-09-01", end: y[2] + "-06-30" };
    var ym = s.match(/^(\d{4})[./-](\d{1,2})\s*[-~～]\s*(\d{4})[./-](\d{1,2})$/);
    if (ym) {
      return {
        start: ym[1] + "-" + pad2(+ym[2]) + "-01",
        end: ym[3] + "-" + pad2(+ym[4]) + "-" + pad2(daysInMonth(+ym[3], +ym[4]))
      };
    }
    return { start: normalizeDate(s), end: "" };
  }

  function formatRange(start, end) {
    if (start && end) return start + " ~ " + end;
    return start || end || "";
  }

  function openMask(title, bodyHtml, footHtml) {
    closePicker();
    var mask = document.createElement("div");
    mask.id = "q-picker-mask";
    mask.className = "picker-mask";
    mask.innerHTML =
      '<div class="picker-panel" role="dialog" aria-modal="true">' +
      '<div class="picker-head"><h3>' + title + '</h3><button type="button" class="picker-x" aria-label="关闭">×</button></div>' +
      bodyHtml +
      '<div class="picker-foot">' + (footHtml || "") + "</div></div>";
    document.body.appendChild(mask);
    mask.addEventListener("click", function (e) {
      if (e.target === mask) closePicker();
    });
    mask.querySelector(".picker-x").addEventListener("click", closePicker);
    return mask;
  }

  function guessFromValue(value) {
    var sel = { p: 0, c: 0, d: -1 };
    var parts = (value || "").split(/\s*\/\s*/).map(function (x) { return x.trim(); }).filter(Boolean);
    if (!parts.length) return sel;
    var list = provinces();
    for (var i = 0; i < list.length; i++) {
      if (list[i][0] === parts[0] || list[i][0].indexOf(parts[0]) === 0 || parts[0].indexOf(list[i][0].replace(/市$|省$|自治区$|特别行政区$/, "")) === 0) {
        sel.p = i;
        var cities = list[i][1];
        if (parts[1]) {
          for (var j = 0; j < cities.length; j++) {
            if (cities[j][0] === parts[1] || cities[j][0].indexOf(parts[1]) === 0) {
              sel.c = j;
              if (parts[2]) {
                var ds = cities[j][1];
                for (var k = 0; k < ds.length; k++) {
                  if (ds[k] === parts[2]) sel.d = k;
                }
              }
              break;
            }
          }
        }
        return sel;
      }
    }
    var needle = parts[parts.length - 1];
    for (i = 0; i < list.length; i++) {
      var cities2 = list[i][1];
      for (var cj = 0; cj < cities2.length; cj++) {
        if (cities2[cj][0].indexOf(needle) >= 0 || needle.indexOf(cities2[cj][0].replace(/市$/, "")) >= 0) {
          sel.p = i;
          sel.c = cj;
          return sel;
        }
        var ds2 = cities2[cj][1];
        for (var dk = 0; dk < ds2.length; dk++) {
          if (ds2[dk] === needle) {
            sel.p = i;
            sel.c = cj;
            sel.d = dk;
            return sel;
          }
        }
      }
    }
    return sel;
  }

  function openRegion(input) {
    var list = provinces();
    var sel = guessFromValue(input.value);
    var mask = openMask(
      "选择地区",
      '<div class="picker-crumb" id="q-region-crumb"></div><div class="picker-cols">' +
        '<div class="picker-col" id="q-col-p"><b>省 / 直辖市 / 特区</b></div>' +
        '<div class="picker-col" id="q-col-c"><b>市 / 州</b></div>' +
        '<div class="picker-col" id="q-col-d"><b>区县</b></div></div>',
      '<button type="button" class="btn-lite" id="q-region-clear">清除</button>' +
        '<button type="button" class="primary inline" id="q-region-ok">确定</button>'
    );

    function applyValue() {
      var p = list[sel.p];
      if (!p) return;
      var c = p[1][sel.c];
      var text = p[0];
      if (c) {
        text += " / " + c[0];
        if (sel.d >= 0 && c[1][sel.d]) text += " / " + c[1][sel.d];
      }
      input.value = text;
      input.dispatchEvent(new Event("change", { bubbles: true }));
      closePicker();
    }

    function render() {
      var p = list[sel.p];
      var cities = p ? p[1] : [];
      var city = cities[sel.c];
      var districts = city ? city[1] : [];
      var crumb = p ? p[0] : "请选择省份";
      if (city) crumb += " › " + city[0];
      if (sel.d >= 0 && districts[sel.d]) crumb += " › " + districts[sel.d];
      else crumb += " › 选择区县";
      mask.querySelector("#q-region-crumb").textContent = crumb;

      var colP = mask.querySelector("#q-col-p");
      var colC = mask.querySelector("#q-col-c");
      var colD = mask.querySelector("#q-col-d");
      colP.innerHTML = "<b>省 / 直辖市 / 特区</b>";
      colC.innerHTML = "<b>市 / 州</b>";
      colD.innerHTML = "<b>区县</b>";
      list.forEach(function (item, i) {
        var btn = document.createElement("button");
        btn.type = "button";
        btn.textContent = item[0];
        if (i === sel.p) btn.className = "on";
        btn.addEventListener("click", function () {
          sel.p = i;
          sel.c = 0;
          sel.d = -1;
          render();
        });
        colP.appendChild(btn);
      });
      cities.forEach(function (item, i) {
        var btn = document.createElement("button");
        btn.type = "button";
        btn.textContent = item[0];
        if (i === sel.c) btn.className = "on";
        btn.addEventListener("click", function () {
          sel.c = i;
          sel.d = -1;
          render();
        });
        colC.appendChild(btn);
      });
      districts.forEach(function (item, i) {
        var btn = document.createElement("button");
        btn.type = "button";
        btn.textContent = item;
        if (i === sel.d) btn.className = "on";
        btn.addEventListener("click", function () {
          sel.d = i;
          render();
          applyValue();
        });
        colD.appendChild(btn);
      });
      [colP, colC, colD].forEach(function (col) {
        var on = col.querySelector("button.on");
        if (on && on.scrollIntoView) on.scrollIntoView({ block: "nearest" });
      });
    }

    mask.querySelector("#q-region-ok").addEventListener("click", applyValue);
    mask.querySelector("#q-region-clear").addEventListener("click", function () {
      input.value = "";
      input.dispatchEvent(new Event("change", { bubbles: true }));
      closePicker();
    });
    render();
  }

  function fillYears(select, from, to, current) {
    select.innerHTML = "";
    for (var y = to; y >= from; y--) {
      var opt = document.createElement("option");
      opt.value = String(y);
      opt.textContent = y + " 年";
      if (y === current) opt.selected = true;
      select.appendChild(opt);
    }
  }

  function fillNums(select, from, to, current, suffix) {
    select.innerHTML = "";
    for (var n = from; n <= to; n++) {
      var opt = document.createElement("option");
      opt.value = String(n);
      opt.textContent = n + suffix;
      if (n === current) opt.selected = true;
      select.appendChild(opt);
    }
  }

  function parseYmd(value) {
    var n = normalizeDate(value);
    var d = n.match(/^(\d{4})-(\d{2})-(\d{2})$/);
    var now = new Date();
    if (!d) {
      return { y: now.getFullYear(), m: now.getMonth() + 1, d: now.getDate() };
    }
    return { y: +d[1], m: +d[2], d: +d[3] };
  }

  function openCalendar(input, onPick) {
    var cur = parseYmd(input.value);
    var mask = openMask(
      "选择年月日",
      '<div class="cal-body">' +
        '<div class="cal-wheels">' +
        '<div><label>年</label><select id="q-cal-y"></select></div>' +
        '<div><label>月</label><select id="q-cal-m"></select></div>' +
        '<div><label>日</label><select id="q-cal-d"></select></div></div>' +
        '<div class="cal-grid"><div class="cal-week">' +
        "<span>日</span><span>一</span><span>二</span><span>三</span><span>四</span><span>五</span><span>六</span>" +
        '</div><div class="cal-days" id="q-cal-grid"></div></div></div>',
      '<button type="button" class="btn-lite" id="q-cal-clear">清除</button>' +
        '<button type="button" class="primary inline" id="q-cal-ok">确定</button>'
    );
    var ySel = mask.querySelector("#q-cal-y");
    var mSel = mask.querySelector("#q-cal-m");
    var dSel = mask.querySelector("#q-cal-d");
    fillYears(ySel, 1950, 2036, cur.y);
    fillNums(mSel, 1, 12, cur.m, " 月");

    function syncDaySelect() {
      var max = daysInMonth(+ySel.value, +mSel.value);
      if (cur.d > max) cur.d = max;
      fillNums(dSel, 1, max, cur.d, " 日");
    }

    function paintGrid() {
      var y = +ySel.value;
      var m = +mSel.value;
      cur.y = y;
      cur.m = m;
      cur.d = +dSel.value;
      var grid = mask.querySelector("#q-cal-grid");
      grid.innerHTML = "";
      var first = new Date(y, m - 1, 1).getDay();
      var max = daysInMonth(y, m);
      var i;
      for (i = 0; i < first; i++) {
        var empty = document.createElement("button");
        empty.type = "button";
        empty.className = "mute";
        empty.disabled = true;
        empty.textContent = "";
        grid.appendChild(empty);
      }
      for (i = 1; i <= max; i++) {
        var btn = document.createElement("button");
        btn.type = "button";
        btn.textContent = String(i);
        if (i === cur.d) btn.className = "on";
        btn.addEventListener("click", function (day) {
          return function () {
            cur.d = day;
            dSel.value = String(day);
            paintGrid();
          };
        }(i));
        grid.appendChild(btn);
      }
    }

    function commit() {
      var value = ySel.value + "-" + pad2(+mSel.value) + "-" + pad2(+dSel.value);
      if (onPick) onPick(value);
      else {
        input.value = value;
        input.dispatchEvent(new Event("change", { bubbles: true }));
      }
      closePicker();
    }

    ySel.addEventListener("change", function () { syncDaySelect(); paintGrid(); });
    mSel.addEventListener("change", function () { syncDaySelect(); paintGrid(); });
    dSel.addEventListener("change", paintGrid);
    mask.querySelector("#q-cal-ok").addEventListener("click", commit);
    mask.querySelector("#q-cal-clear").addEventListener("click", function () {
      if (onPick) onPick("");
      else {
        input.value = "";
        input.dispatchEvent(new Event("change", { bubbles: true }));
      }
      closePicker();
    });
    syncDaySelect();
    paintGrid();
  }

  function bindRange(wrap) {
    if (wrap.dataset.bound) return;
    wrap.dataset.bound = "1";
    var hidden = wrap.querySelector('input[type="hidden"]');
    var start = wrap.querySelector(".js-date-start");
    var end = wrap.querySelector(".js-date-end");
    if (!hidden || !start || !end) return;
    var parsed = parseRange(hidden.value);
    start.value = parsed.start;
    end.value = parsed.end;
    function sync() {
      hidden.value = formatRange(start.value, end.value);
    }
    start.addEventListener("click", function () {
      openCalendar(start, function (v) {
        start.value = v;
        sync();
      });
    });
    end.addEventListener("click", function () {
      openCalendar(end, function (v) {
        end.value = v;
        sync();
      });
    });
  }

  function bindAll(root) {
    (root || document).querySelectorAll(".js-region").forEach(function (input) {
      if (input.dataset.bound) return;
      input.dataset.bound = "1";
      input.readOnly = true;
      input.addEventListener("click", function () { openRegion(input); });
    });
    (root || document).querySelectorAll(".js-date").forEach(function (input) {
      if (input.dataset.bound) return;
      input.dataset.bound = "1";
      input.readOnly = true;
      if (input.type === "date") input.type = "text";
      input.addEventListener("click", function () { openCalendar(input); });
    });
    (root || document).querySelectorAll(".js-daterange").forEach(bindRange);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", function () { bindAll(document); });
  } else {
    bindAll(document);
  }
  window.QPickers = { bind: bindAll, close: closePicker };
})();
