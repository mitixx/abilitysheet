scores = null;
serverUrlBase = 'http://localhost:3000';
login = false;
user = {}
timeout = 100
$.ajaxSetup({ xhrFields: { withCredentials: true } });

// TODO: konamiのメンテナンス時間とログインしていない場合の対応
// TODO: konamiにログインしていない場合の対応

function getUserInfo() {
  $.ajax({
    type: 'get',
    url: 'http://p.eagate.573.jp/game/2dx/24/p/djdata/status.html',
    async: false,
    success: function(data) {
      canvas = document.createElement('canvas');
      qpros = $(data).find('img').filter(function(index, element) {
        return element.attributes.src.value.includes('img_qpro.html') }
      );
      qpro = qpros[0];
      canvas.width = qpro.width;
      canvas.height = qpro.height;

      ctx = canvas.getContext('2d');
      ctx.drawImage(qpro, 0, 0);
      setTimeout(function() { user.image = canvas.toDataURL('image/png'); }, timeout);
      user.djname = $($(data).find('table#dj_data_table > tbody > tr')[0]).find('td').text();
      user.grade = $($(data).find('td.point')[5]).text();
    },
  });
}

function checkStatus() {
  $.ajax({
    type: 'get',
    url: serverUrlBase + '/api/v1/users/status',
    async: false,
    dataType: 'json',
    success: function(data) { login = data.status ? true : false; }
  });
}

function getCsv() {
  $.ajax({
    type: 'post',
    url: 'http://p.eagate.573.jp/game/2dx/24/p/djdata/score_download.html',
    async: false,
    data: { style: 0 },
    success: function(data) { scores = $(data).find('#score_data').text() }
  });
}

function putData() {
  $.ajax({
    type: 'post',
    url: serverUrlBase + '/api/v1/scores/sync/official',
    contentType: 'application/json',
    data: JSON.stringify({ scores: scores, user: user }),
    success: function(data) { alert('success'); }
  });
}

checkStatus();
if (login) {
  getUserInfo();
  getCsv();
  setTimeout(putData, timeout);
} else {
  alert('please login: https://iidx12.tk');
}
