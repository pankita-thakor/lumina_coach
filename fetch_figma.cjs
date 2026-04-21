const http = require('http');

http.get('http://localhost:3000/figma', (res) => {
  let data = '';
  res.on('data', (chunk) => { data += chunk; });
  res.on('end', () => {
    try {
      const json = JSON.parse(data);
      const canvas = json.document.children.find(c => c.type === 'CANVAS');
      if (!canvas) {
        console.log('No canvas found');
        return;
      }
      const signIn = canvas.children.find(c => c.name === 'Sign In');
      if (!signIn) {
        console.log('No "Sign In" frame found');
        return;
      }
      console.log(JSON.stringify(signIn, null, 2));
    } catch (e) {
      console.error('Error parsing JSON:', e.message);
    }
  });
}).on('error', (err) => {
  console.error('Error:', err.message);
});
