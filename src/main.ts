import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import VueLatex from 'vatex'

createApp(App)
  .use(VueLatex)
  .use(router)
  .use(ElementPlus)
  .mount('#app')
