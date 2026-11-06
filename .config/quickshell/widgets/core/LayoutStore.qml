pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "."

Singleton {
    id: root

    readonly property string layoutPath:
        Quickshell.env("HOME") + "/.config/quickshell/widgets/layout.json"

    // grid
    property int cell: 80
    property int gap: 12
    property int margin: 24
    // style
    property real radius: 22
    property real cardOpacity: 0.93
    property int padding: 16
    property string fontFamily: "Nunito"
    // content
    property string activeProfile: "default"
    property var profileNames: []
    property var widgets: []
    property alias idModel: _ids        // one entry per widget, so cards update in place

    // grid size in cells (set by WidgetLayer from the window size)
    property int gridCols: 1
    property int gridRows: 1

    // editor state
    property bool editMode: false
    property string selectedId: ""
    property string dragId: ""
    property bool panelOpen: true
    property int panelTab: 0            // 0 Library, 1 Properties, 2 Style, 3 Profiles
    signal focusEditor()

    // history
    property var undoStack: []
    property var redoStack: []
    property string lastKey: ""
    readonly property bool canUndo: undoStack.length > 0
    readonly property bool canRedo: redoStack.length > 0

    // full parsed file, so other profiles and unknown keys survive saves
    property var doc: null
    property var written: []            // recent saves, so we can ignore our own file-watcher echoes

    readonly property var defaults: ({
        version: 1,
        grid: { cell: 80, gap: 12, margin: 24 },
        style: { radius: 22, opacity: 0.93, padding: 16, font: "Nunito" },
        activeProfile: "default",
        profiles: {
            "default": {
                widgets: [
                    { id: "clock-1",    type: "clock",    x: 0, y: 0, w: 2, h: 2,
                      settings: { format: "24h", showDate: true } },
                    { id: "weather-1",  type: "weather",  x: 2, y: 0, w: 3, h: 1,
                      settings: { units: "metric", location: "auto" } },
                    { id: "battery-1",  type: "battery",  x: 2, y: 1, w: 3, h: 1,
                      settings: {} },
                    { id: "calendar-1", type: "calendar", x: 0, y: 2, w: 3, h: 3,
                      settings: { mondayFirst: false } }
                ]
            }
        }
    })

    ListModel { id: _ids }

    // selecting a widget jumps to its Properties tab
    onSelectedIdChanged: if (selectedId !== "") panelTab = 1

    // leaving edit mode writes any pending save right away
    onEditModeChanged: {
        if (!editMode && saveTimer.running) {
            saveTimer.stop();
            flush();
        }
    }

    // ---------- grid math ----------
    function px(cells) { return cells * cell + Math.max(0, cells - 1) * gap; }
    function posX(x)   { return margin + x * (cell + gap); }
    function posY(y)   { return margin + y * (cell + gap); }

    // ---------- queries ----------
    function find(id) {
        for (const w of widgets)
            if (w.id === id) return w;
        return null;
    }

    function limits(type) {
        const i = WidgetRegistry.info(type) ?? {};
        return {
            minW: i.minW ?? 1, minH: i.minH ?? 1,
            maxW: i.maxW ?? 12, maxH: i.maxH ?? 12
        };
    }

    // Is this rectangle (in cells) inside the grid and free of other widgets?
    function fits(id, x, y, w, h) {
        if (x < 0 || y < 0 || x + w > gridCols || y + h > gridRows) return false;
        for (const o of widgets) {
            if (o.id === id) continue;
            if (x < o.x + o.w && x + w > o.x && y < o.y + o.h && y + h > o.y)
                return false;
        }
        return true;
    }

    function freeSpot(w, h) {
        for (let y = 0; y + h <= gridRows; y++)
            for (let x = 0; x + w <= gridCols; x++)
                if (fits("", x, y, w, h)) return { x: x, y: y };
        return null;
    }

    function nextId(type) {
        let n = 1;
        while (find(type + "-" + n)) n++;
        return type + "-" + n;
    }

    function profileWidgets(name) {
        if (name === activeProfile) return widgets;
        return doc?.profiles?.[name]?.widgets ?? [];
    }

    // ---------- history ----------
    function snapshot() {
        return JSON.stringify({
            widgets: widgets,
            style: { radius: radius, opacity: cardOpacity, padding: padding, font: fontFamily },
            grid: { cell: cell, gap: gap, margin: margin }
        });
    }

    // Call right BEFORE changing state. Edits sharing a non-empty key within
    // 700ms of each other collapse into a single undo step.
    function record(key) {
        if (key !== "" && key === lastKey && coalesce.running) {
            coalesce.restart();
            return;
        }
        undoStack = undoStack.concat([snapshot()]).slice(-100);
        redoStack = [];
        lastKey = key;
        coalesce.restart();
    }

    function clearHistory() {
        undoStack = [];
        redoStack = [];
        lastKey = "";
        coalesce.stop();
    }

    function restore(s) {
        const d = JSON.parse(s);
        radius      = d.style.radius;
        cardOpacity = d.style.opacity;
        padding     = d.style.padding;
        fontFamily  = d.style.font;
        cell        = d.grid.cell;
        gap         = d.grid.gap;
        margin      = d.grid.margin;
        widgets     = d.widgets;
        if (selectedId !== "" && !find(selectedId)) selectedId = "";
        syncIds();
        save();
    }

    function undo() {
        if (undoStack.length === 0 || dragId !== "") return;
        const prev = undoStack[undoStack.length - 1];
        redoStack = redoStack.concat([snapshot()]);
        undoStack = undoStack.slice(0, -1);
        lastKey = "";
        coalesce.stop();
        restore(prev);
    }

    function redo() {
        if (redoStack.length === 0 || dragId !== "") return;
        const next = redoStack[redoStack.length - 1];
        undoStack = undoStack.concat([snapshot()]);
        redoStack = redoStack.slice(0, -1);
        lastKey = "";
        coalesce.stop();
        restore(next);
    }

    Timer {
        id: coalesce
        interval: 700
        onTriggered: root.lastKey = ""
    }

    // ---------- widget mutations ----------
    function setRect(id, x, y, w, h) {
        record("");
        widgets = widgets.map(wd => wd.id === id
            ? Object.assign({}, wd, { x: x, y: y, w: w, h: h })
            : wd);
        save();
    }

    function setSetting(id, key, value) {
        record("");
        widgets = widgets.map(wd => {
            if (wd.id !== id) return wd;
            const s = Object.assign({}, wd.settings ?? {});
            s[key] = value;
            return Object.assign({}, wd, { settings: s });
        });
        save();
    }
        // value null/undefined removes the override (the widget goes back to the global style)
    function setWidgetStyle(id, key, value) {
        record("wstyle:" + id + ":" + key);
        widgets = widgets.map(wd => {
            if (wd.id !== id) return wd;
            const s = Object.assign({}, wd.style ?? {});
            if (value === null || value === undefined) delete s[key];
            else s[key] = value;
            const out = Object.assign({}, wd);
            if (Object.keys(s).length > 0) out.style = s;
            else delete out.style;
            return out;
        });
        save();
    }

    function resetWidgetStyle(id) {
        record("");
        widgets = widgets.map(wd => {
            if (wd.id !== id) return wd;
            const out = Object.assign({}, wd);
            delete out.style;
            return out;
        });
        save();
    }

    function setStyle(key, value) {
        record("style:" + key);
        if (key === "radius")       radius = value;
        else if (key === "opacity") cardOpacity = value;
        else if (key === "padding") padding = value;
        else if (key === "font")    fontFamily = value;
        save();
    }

    function setGrid(key, value) {
        record("grid:" + key);
        if (key === "cell")        cell = value;
        else if (key === "gap")    gap = value;
        else if (key === "margin") margin = value;
        save();
    }

    // returns the new id, or "" if there was no room
    function addWidget(type) {
        const info = WidgetRegistry.info(type);
        if (!info) return "";

        let w = info.defaultW, h = info.defaultH;
        let spot = freeSpot(w, h);
        if (!spot) {                         // try the smallest allowed size
            w = info.minW; h = info.minH;
            spot = freeSpot(w, h);
        }
        if (!spot) return "";

        const id = nextId(type);
        record("");
        widgets = widgets.concat([{
            id: id, type: type, x: spot.x, y: spot.y, w: w, h: h,
            settings: WidgetRegistry.defaultSettings(type)
        }]);
        syncIds();
        selectedId = id;
        save();
        return id;
    }

    function duplicateWidget(id) {
        const src = find(id);
        if (!src) return "";
        const spot = freeSpot(src.w, src.h);
        if (!spot) return "";

        const copy = JSON.parse(JSON.stringify(src));
        copy.id = nextId(src.type);
        copy.x = spot.x;
        copy.y = spot.y;
        record("");
        widgets = widgets.concat([copy]);
        syncIds();
        selectedId = copy.id;
        save();
        return copy.id;
    }

    function removeWidget(id) {
        if (!find(id)) return;
        record("");
        widgets = widgets.filter(wd => wd.id !== id);
        if (selectedId === id) selectedId = "";
        syncIds();
        save();
    }

    function resetLayout() {
        record("");
        widgets = JSON.parse(JSON.stringify(defaults.profiles["default"].widgets));
        selectedId = "";
        syncIds();
        save();
    }

    function resetStyle() {
        record("");
        const s = defaults.style, g = defaults.grid;
        radius = s.radius; cardOpacity = s.opacity; padding = s.padding; fontFamily = s.font;
        cell = g.cell; gap = g.gap; margin = g.margin;
        save();
    }

    // add/remove only the ids that changed, so other cards are not rebuilt
    function syncIds() {
        const want = widgets.map(w => w.id);
        for (let i = _ids.count - 1; i >= 0; i--)
            if (want.indexOf(_ids.get(i).itemId) < 0) _ids.remove(i);
        const have = [];
        for (let i = 0; i < _ids.count; i++) have.push(_ids.get(i).itemId);
        for (const id of want)
            if (have.indexOf(id) < 0) _ids.append({ itemId: id });
    }

    // ---------- profiles ----------
    function refreshProfileNames() {
        const next = Object.keys(doc?.profiles ?? {});
        if (JSON.stringify(next) !== JSON.stringify(profileNames))
            profileNames = next;
    }

    function uniqueName(base) {
        let n = String(base ?? "").trim().slice(0, 32);
        if (n === "") n = "Layout";
        if (profileNames.indexOf(n) < 0) return n;
        let i = 2;
        while (profileNames.indexOf(n + " " + i) >= 0) i++;
        return n + " " + i;
    }

    // clone the current doc, let fn edit it, and store it
    function mutateDoc(fn) {
        const d = JSON.parse(JSON.stringify(buildDoc()));
        fn(d);
        doc = d;
        refreshProfileNames();
        saveTimer.restart();
    }

    function switchProfile(name) {
        if (name === activeProfile) return;
        const d = buildDoc();               // capture the current profile first
        if (!d.profiles[name]) return;
        activeProfile = name;
        widgets = JSON.parse(JSON.stringify(d.profiles[name].widgets ?? []));
        selectedId = "";
        dragId = "";
        clearHistory();
        syncIds();
        save();
    }

    function createProfile(name, list) {
        const n = uniqueName(name);
        mutateDoc(d => { d.profiles[n] = { widgets: list ?? [] }; });
        switchProfile(n);
        return n;
    }

    function duplicateProfile(name) {
        const copy = JSON.parse(JSON.stringify(profileWidgets(name)));
        return createProfile(name + " copy", copy);
    }

    function renameProfile(oldName, newName) {
        const n = String(newName ?? "").trim().slice(0, 32);
        if (n === "" || n === oldName || profileNames.indexOf(n) >= 0) return false;
        mutateDoc(d => {
            const out = {};
            for (const k of Object.keys(d.profiles))
                out[k === oldName ? n : k] = d.profiles[k];
            d.profiles = out;
            if (d.activeProfile === oldName) d.activeProfile = n;
        });
        if (activeProfile === oldName) activeProfile = n;
        return true;
    }

    function deleteProfile(name) {
        if (profileNames.length <= 1) return false;
        if (name === activeProfile)
            switchProfile(profileNames.find(p => p !== name));
        mutateDoc(d => { delete d.profiles[name]; });
        return true;
    }

    // keep only well-formed, non-overlapping widgets
    function sanitizeWidgets(list) {
        const out = [];
        const seen = {};
        for (const w of (Array.isArray(list) ? list : [])) {
            if (!w || typeof w.type !== "string") continue;
            if (![w.x, w.y, w.w, w.h].every(v => Number.isInteger(v))) continue;
            if (w.x < 0 || w.y < 0 || w.w < 1 || w.h < 1) continue;
            if (out.some(o => w.x < o.x + o.w && w.x + w.w > o.x
                           && w.y < o.y + o.h && w.y + w.h > o.y)) continue;

            const base = (typeof w.id === "string" && w.id !== "") ? w.id : w.type + "-1";
            let id = base;
            let n = 2;
            while (seen[id]) id = base + "-" + (n++);
            seen[id] = true;

            const item = {
                id: id, type: w.type, x: w.x, y: w.y, w: w.w, h: w.h,
                settings: (w.settings && typeof w.settings === "object") ? w.settings : {}
            };
            if (w.style && typeof w.style === "object") item.style = w.style;
            out.push(item);
        }
        return out;
    }

    function importProfile(name, list) {
        const clean = sanitizeWidgets(list);
        const n = createProfile(name, clean);
        return {
            name: n,
            kept: clean.length,
            skipped: (Array.isArray(list) ? list.length : 0) - clean.length
        };
    }

    // ---------- loading / saving ----------
    function apply(data) {
        doc = JSON.parse(JSON.stringify(data));
        const g = data.grid ?? {};
        const s = data.style ?? {};
        cell        = g.cell ?? 80;
        gap         = g.gap ?? 12;
        margin      = g.margin ?? 24;
        radius      = s.radius ?? 22;
        cardOpacity = s.opacity ?? 0.93;
        padding     = s.padding ?? 16;
        fontFamily  = s.font ?? "Nunito";
        activeProfile = data.activeProfile ?? "default";
        widgets = (data.profiles ?? {})[activeProfile]?.widgets ?? [];
        refreshProfileNames();
        clearHistory();
        syncIds();
    }

    // merge current state into the doc and return it
    function buildDoc() {
        const d = JSON.parse(JSON.stringify(doc ?? defaults));
        d.version = d.version ?? 1;
        d.grid = Object.assign({}, d.grid, { cell: cell, gap: gap, margin: margin });
        d.style = Object.assign({}, d.style, {
            radius: radius, opacity: cardOpacity, padding: padding, font: fontFamily
        });
        d.activeProfile = activeProfile;
        d.profiles = d.profiles ?? {};
        d.profiles[activeProfile] = Object.assign({}, d.profiles[activeProfile], {
            widgets: JSON.parse(JSON.stringify(widgets))
        });
        doc = d;
        return d;
    }

    function save() {
        buildDoc();
        refreshProfileNames();
        saveTimer.restart();
    }

    function flush() {
        if (!doc) return;
        const t = JSON.stringify(doc, null, 2);
        written = written.concat([t]).slice(-6);
        file.setText(t);
    }

    Timer {
        id: saveTimer
        interval: 250
        onTriggered: root.flush()
    }

    FileView {
        id: file
        path: root.layoutPath
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            const t = text();
            if (root.written.indexOf(t) >= 0) return;   // our own save echoing back
            try {
                root.apply(JSON.parse(t));
            } catch (e) {
                console.warn("LayoutStore: bad layout.json:", e);
            }
        }
        onLoadFailed: (error) => {
            if (error === FileViewError.FileNotFound) {
                root.apply(root.defaults);
                root.save();
            }
        }
    }
}