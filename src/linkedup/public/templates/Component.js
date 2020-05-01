import { deepEquals, updateById } from "../utils";

class Component {
  constructor(selector = "", template = () => {}) {
    this.selector = selector;
    this.template = template;
    this.state = {};
  }

  update(newState) {
    if (!deepEquals(this.state, newState)) {
      this.state = { ...newState };
      this.render();
    }
  }

  render() {
    updateById(this.selector, this.template(this.state));
  }
}

export default Component;
