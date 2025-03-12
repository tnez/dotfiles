<script>
  let name = "World";
  let count = 0;

  function incrementCount() {
    count += 1;
  }
</script>

<main>
  <h1>Hello {name}!</h1>
  <p>This is a simple Svelte demo for testing auto-reload in Neovim</p>

  <div class="card">
    <button on:click={incrementCount}>
      Count is {count}
    </button>
  </div>

  <p class="update-message">
    Try editing this file in another terminal to see the auto-reload in action!
  </p>
</main>

<style>
  main {
    max-width: 800px;
    margin: 0 auto;
    padding: 2rem;
    text-align: center;
  }

  h1 {
    color: #ff3e00;
    text-transform: uppercase;
    font-size: 2.5rem;
    font-weight: 100;
  }

  .card {
    margin: 2rem auto;
    padding: 2rem;
    border: 1px solid #eee;
    border-radius: 8px;
  }

  button {
    background-color: #ff3e00;
    color: white;
    border: none;
    padding: 0.75rem 1.5rem;
    border-radius: 4px;
    cursor: pointer;
    font-size: 1rem;
  }

  button:hover {
    background-color: #cc3200;
  }

  .update-message {
    color: #555;
    font-style: italic;
    margin-top: 2rem;
  }
</style>

