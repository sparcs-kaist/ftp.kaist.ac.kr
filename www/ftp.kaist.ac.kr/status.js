/*
 * status.js -- update status page without reloading using AJAX
 * 
 * Created: 2006-04-09
 * 
 * Written by Jaeho Shin <netj@sparcs.org>.
 * (C) 2006, Geoul Project. (http://ftp.kaist.ac.kr/geoul)
 */

var pkgindexurl = '/pkgstat.xml';

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
        http_request.open('GET', pkgindexurl, true);
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
                pkgid = pkg.getAttribute('id');
                var box = document.getElementById('pkg-' + pkgid);
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
                box.className = 'pkg';
                var sync = pkg.selectSingleNode('sync');
                var frequency;
                // updating status
                if (sync) {
                    setText(field(box,'source'), getText(sync));
                    if (frequency = sync.getAttribute('frequency')) {
                        frequency = formatSeconds(frequency);
                        setText(field(box,'frequency'), frequency);
                    } else
                        setText(field(box,'frequency'), w('none'));
                    var syncinfo = field(box,'sync');
                    syncinfo.className = 'pkgsync';
                    var started;
                    if (started = sync.getAttribute('started')) {
                        box.className += ' sync';
                        setText(field(box,'syncage'),
                                formatSeconds((now-isoDate(started))/1000));
                        syncinfo.className += ' up';
                    }
                    var failed;
                    if (failed = sync.getAttribute('failed')) {
                        setText(field(box,'syncfailed'), failed);
                        field(box,'syncfailures').style.display = 'inline';
                    } else {
                        field(box,'syncfailures').style.display = 'none';
                    }
                }
                // status
                var status = pkg.selectSingleNode('status');
                if (status) {
                    var statustxt = getText(status);
                    setText(field(box,'status').getElementsByTagName('a')[0],
                        w('status_' + statustxt));
                    box.className += ' ' + statustxt;
                    var lastupdated;
                    if (lastupdated = status.getAttribute('lastupdated')) {
                        lastupdated = isoDate(lastupdated);
                        setText(field(box,'lastupdated'), formatDate(lastupdated, true));
                        if (frequency)
                            setText(field(box,'age'),
                                formatSeconds((now-lastupdated)/1000)
                                + ' / ' + frequency);
                        else
                            setText(field(box,'age'), w(''));
                    } else {
                        // no timestamp
                        setText(field(box,'lastupdated'), w(''));
                        setText(field(box,'age'), w(''));
                    }
                } else {
                    setText(field(box,'status'), w('unknown'));
                    setText(field(box,'lastupdated'), w(''));
                    setText(field(box,'age'), w(''));
                }
            }
            setText(document.getElementById("lastupdated"),
                    formatDate(now));
        }
        document.getElementById('pkgs').className = '';
    }

}

window.onload = refresh;
