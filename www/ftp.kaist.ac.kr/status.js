/*
 * status.js -- update status page without reloading using AJAX
 * 
 * Created: 2006-04-09
 * 
 * Written by Jaeho Shin <netj@sparcs.org>.
 * (C) 2006, Geoul Project. (http://ftp.kaist.ac.kr/geoul)
 */

var pkgstaturl = '/pkgstat.xml';

var monthnames = "Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec".split(',');
function isoDate(isoStr) {
    var dt = isoStr.replace(/([+-]..:..|Z)$/, '');
    var zone = isoStr.replace(dt, '');
    if (zone == 'Z') zone = '';
    else zone = zone.replace(':','');
    var t = dt.split(/[T-]/);
    return new Date(
        monthnames[t[1]-1]+' '+t[2]+', '+t[0]+ ' ' +t[3]+' GMT'+zone);
}

function formatSeconds(secs) {
    var min = parseInt(secs % 3600 / 60);
    if (min < 10) min = '0' + min;
    return parseInt(secs / 3600) + ':' + min;
}


function getText(e) {
    if (e.textContent) // Gecko
        return e.textContent;
    else if (e.nodeValue)
        return e.nodeValue;
    else {
        var t = "";
        for (var i=0; i<e.childNodes.length; i++)
            t += getText(e.childNodes[i]);
        return t;
    }
}
function setText(e,t) {
    if (e == null)
        return;
    if (!e.firstChild) 
        e.appendChild(document.createTextNode(t));
    else
        e.replaceChild(document.createTextNode(t), e.firstChild);
}

var forms = [];
function formfor(pkgid) {
    for (var i=0; i<forms.length; i++) {
        if (forms[i].id == pkgid)
            return forms[i];
    }
    return null;
}

function init() {
    document.getElementById("pkgsinfo").className += ' active';
    var links = document.getElementById("pkgsidx").getElementsByTagName("a");
    for (var i=0; i<links.length; i++) {
        var link = links[i];
        var pkgid = links[i].hash.replace(/^#/, '');
        var box = document.getElementById(pkgid);
        if (! box)
            continue;
        function field(box, name, e) {
            e = (e) ? e : box;
            var cls = new RegExp('(^| )pkg'+name + '($| )');
            var cs = e.childNodes;
            for (var i=0; i<cs.length; i++)
                if (cls.exec(cs[i].className))
                    return cs[i];
            for (var i=0; i<cs.length; i++) {
                var f = field(box, name, cs[i]);
                if (f) return f;
            }
            return null;
        }
        box.className += ' inactive';
        forms.push({
            id              : pkgid,
            link            : link,
            frame           : box,
            source          : field(box, 'source'),
            frequency       : field(box, 'frequency'),
            //box             : field(box, 'box'),
            sync            : field(box, 'sync'),
            syncref         : field(box, 'syncref'),
            syncage         : field(box, 'syncage'),
            syncfailed      : field(box, 'syncfailed'),
            syncfailures    : field(box, 'syncfailures'),
            status          : field(box, 'status'),
            lastupdated     : field(box, 'lastupdated'),
            age             : field(box, 'age'),
            sizegraph       : field(box, 'sizegraph')
        });
    }
}


var refreshTimer;
function refreshRegularly(interval) {
    if (refreshTimer)
        clearInterval(refreshTimer);
    if (interval == "")
        refreshTimer = null;
    else
        refreshTimer = window.setInterval(refresh, interval * 1000);
}

function refresh() {
    var http_request = false;
    if (window.XMLHttpRequest) { // Mozilla, Safari,...
        http_request = new XMLHttpRequest();
        if (http_request.overrideMimeType) {
            http_request.overrideMimeType('text/xml');
        }
    } else if (window.ActiveXObject) { // IE
        try {
            http_request = new ActiveXObject("Msxml2.XMLHTTP");
        } catch (e) {
            try {
                http_request = new ActiveXObject("Microsoft.XMLHTTP");
            } catch (e) {}
        }
    }
    if (http_request) {
        http_request.onreadystatechange = function() { update(http_request); };
        http_request.open('GET', pkgstaturl, true);
        http_request.send(null);
    } else {
        // AJAX unavailable, just reload
        location.reload();
    }
}

function update(http_request) {
    document.getElementById('pkgs').className = 'updating';
    if (http_request.readyState == 4) {
        if (http_request.status == 200) {
            var xml = http_request.responseXML;
            var pkgs = xml.selectNodes('//package');
            var now = new Date();
            for (var i=0; i<pkgs.length; i++) {
                var pkg = pkgs[i];
                id = pkg.getAttribute('id');
                var form = formfor('pkg-'+id);
                if (! form)
                    continue;
                var statusClassName =
                    (active == form) ? ' active' : ' inactive';
                var sync = pkg.selectSingleNode('sync');
                var frequency;
                // updating status
                if (sync) {
                    setText(form.source, getText(sync));
                    if (frequency = sync.getAttribute('frequency')) {
                        frequency = formatSeconds(frequency);
                        setText(form.frequency, frequency);
                    } else
                        setText(form.frequency, w('none'));
                    var syncinfo = form.sync;
                    syncinfo.className = 'pkgsync';
                    var started;
                    if (started = sync.getAttribute('started')) {
                        statusClassName += ' sync';
                        setText(form.syncage,
                                formatSeconds((now-isoDate(started))/1000));
                        syncinfo.className += ' up';
                    }
                    var syncref;
                    if (syncref = sync.getAttribute('ref'))
                        form.syncref.href = syncref;
                    else
                        form.syncref.href = null;
                    // failures
                    var fail = pkg.selectSingleNode('fail');
                    if (fail) {
                        setText(form.syncfailed, getText(fail));
                        form.syncfailures.style.display = 'inline';
                        var failref;
                        if (failref = fail.getAttribute('ref'))
                            form.syncfailures.href = failref;
                    } else {
                        form.syncfailures.style.display = 'none';
                    }
                }
                // status
                var status = pkg.selectSingleNode('status');
                if (status) {
                    var statustxt = getText(status);
                    setText(form.status, w('status_' + statustxt));
                    statusClassName += ' ' + statustxt;
                    if (form.status) {
                        var statusref;
                        if (statusref = status.getAttribute('ref'))
                            form.status.href = statusref;
                        else
                            form.status.href = null;
                    }
                    var lastupdated;
                    if (lastupdated = status.getAttribute('lastupdated')) {
                        lastupdated = isoDate(lastupdated);
                        setText(form.lastupdated, formatDate(lastupdated, true));
                        if (frequency)
                            setText(form.age,
                                formatSeconds((now-lastupdated)/1000)
                                + ' / ' + frequency);
                        else
                            setText(form.age, w(''));
                    } else {
                        // no timestamp
                        setText(form.lastupdated, w(''));
                        setText(form.age, w(''));
                    }
                } else {
                    setText(form.status, w('unknown'));
                    setText(form.lastupdated, w(''));
                    setText(form.age, w(''));
                }
                form.frame.className = 'pkg'     + statusClassName;
                form.link.className  = 'pkglink' + statusClassName;
                // TODO: refresh graphs
                //form.sizegraph.src = form.sizegraph.src;
            }
            setText(document.getElementById("lastupdated"),
                    formatDate(isoDate(xml.selectSingleNode('/packages')
                    .getAttribute("lastupdated"))));
        }
        document.getElementById('pkgs').className = '';
    }

}

var active;
function toggle(pkgid) {
    var form = formfor(pkgid);
    if (! form)
        return;
    function chClassName(e,from,to) {
        e.className = e.className.replace(from, to);
    }
    function activate(e)   { chClassName(e, ' inactive', ' active'); }
    function inactivate(e) { chClassName(e, ' active', ' inactive'); }
    if (active) { // hide
        inactivate(active.frame);
        inactivate(active.link);
    }
    // toggle
    active = (active == form) ? null : form;
    if (active) { // show
        activate(active.frame);
        activate(active.link);
    }
}

function load() {
    init();
    if (location.hash.match(/^#pkg-/))
        toggle(location.hash.replace(/^#/, ''));
    refresh();
}

window.onload = load;
