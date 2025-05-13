<template>
  <router-view/>
</template>

<script>
// @ is an alias to /src
// import HelloWorld from '@/components/HelloWorld.vue'

export default {
  data () {
    return {
        title_name: 'Haolin Lu \'s Homepage',
    };
  },
  methods: {
  },
}
</script>

<style>

@import "assets/font.css";

#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  /* text-align: center; */
  color: #2c3e50;
}

html, body {
  margin: 0;
  padding: 0;
}

</style>