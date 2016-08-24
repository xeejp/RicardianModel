import React, { Component } from 'react'
import { connect } from 'react-redux'

import Experiment from './Experiment'
import Result from './Result'

const mapStateToProps = ({ page }) => ({
  page
})

const Waiting = () => (
  <div>
    <p>待機画面</p>
  </div>
)

const Description = () => (
  <div>
    <p>説明画面</p>
  </div>
)

const Pages = ({ page }) => {
  switch (page) {
    case "waiting":
      return <Waiting />
    case "description":
      return <Description />
    case "experiment":
      return <Experiment />
    case "result":
      return <Result />
    default:
      return <p>Unreachable!</p>
  }
}

export default connect(mapStateToProps)(Pages)